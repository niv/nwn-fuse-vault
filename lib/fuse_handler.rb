class NWNFuseFS
  UMASK = 0777

  RX_ACCOUNT   = %r{^/([^/]+)$}
  RX_CHARACTER = %r{^/([^/]+?)/(.+?)\.bic$}

  def initialize(handler, uid, gid)
    @handler = handler
    @uid, @gid = uid, gid
    @mknod_path = nil
    @writebuf = {}
  end

  # The root "/" which contains all accounts. We don't list accounts
  # due to performance reasons.
  def stat_for_root
    RFuse::Stat.directory(UMASK, :uid => @uid, :gid => @gid,
                          :atime => Time.now - 10, :mtime => Time.now - 100,
                          :size => 4096)
  end

  # Needed for creating new characters (see mknod).
  def stat_for_empty
    RFuse::Stat.file(UMASK, :uid => @uid, :gid => @gid,
                     :atime => Time.now, :mtime => Time.now,
                     :size => 0)
  end

  # We always return a stat here even if the account doesn't exist
  # so that we don't have to maintain a list of existing accounts.
  # This breaks some shell tools but suits nwserver just fine.
  def stat_for_account account
      RFuse::Stat.directory(UMASK, :uid => @uid, :gid => @gid,
                          :atime => Time.now - 10, :mtime => Time.now - 100,
                          :size => 4096)
  end

  # This raises ENOENT if the character doesn't exist.
  def stat_for_character account, character
    if @handler.get_character_list(account).index(character)
      RFuse::Stat.file(UMASK, :uid => @uid, :gid => @gid,
                       :atime => Time.now - 10, :mtime => Time.now - 100,
                       :size => @handler.get_character_size(account, character))
    else
      path = '/' + account + '/' + character + '.bic'
      raise Errno::ENOENT.new(path)
    end
  end

  def readdir(ctx,path,filler,offset,ffi)
    Log.debug "readdir(?,#{path.inspect},)"

    case path

      when "/"
        # Always return nothing.
        @handler.get_account_list.each do |char|
          stat = stat_for_account(char) # character(account, char)
          filler.push(char, stat, 0)
        end

      when RX_ACCOUNT

        account = $1
        @handler.get_character_list(account).each do |char|
          stat = stat_for_character(account, char)
          filler.push(char + '.bic', stat, 0)
        end

      else
        raise Errno::ENOTDIR.new(path)
    end
  end

  def getattr(ctx, path)
    Log.debug "getattr(?, #{path.inspect})"
    case path

      when "/"
        return stat_for_root

      when RX_CHARACTER
        if @mknod_path == path
          @mknod_path = nil
          return stat_for_empty
        end

        return stat_for_character($1, $2)

      when RX_ACCOUNT
        return stat_for_account($1)

      else

        raise Errno::ENOENT.new(path)
    end
  end

  def read(ctx,path,size,offset,fi)
    Log.debug "readdir(?,#{path.inspect},#{size},#{offset},)"

    case path
      when RX_CHARACTER
        return @handler.load_character($1, $2)[offset..offset + size - 1]
      else
        Log.warn "tried to read non-char file"
        raise Errno::ENOENT.new(path)
    end
  end

  # These are calls nwserver does to maintain the directory structure. Since we
  # do this ourselves, we just drop them.
  def mkdir(ctx,path,mode)
    Log.debug "mkdir #{path.inspect}, ignoring"
  end
  def truncate(ctx,path,offset)
    Log.debug 'truncate ' + path.inspect + ', ignoring'
  end
  def rmdir(ctx,path)
    Log.debug 'rmdir ' + path.inspect + ', ignoring'
  end
  def utime(ctx,path,actime,modtime)
    Log.debug "utime #{path.inspect}, ignoring"
  end
  # We ignore unlink requests, because nwserver never deletes characters by itself.
  def unlink(ctx,path)
    Log.debug "unlink #{path.inspect}, ignoring"
  end

  # We need to catch mknod because that creates a character that doesn't exist yet.
  def mknod(ctx,path,mode,major,minor)
    Log.debug "mknod(#{path},#{major},#{minor})"
    case path
      when RX_CHARACTER
        @mknod_path = path
    end
  end #mknod


  # path => data
  
  def write(ctx,path,buf,offset,fi)
    Log.debug "write(?,#{path.inspect},#{offset},)"

    case path
      when RX_CHARACTER
        @writebuf[path] ||= ""
        @writebuf[path] += buf
        #@handler.save_character $1, $2, buf

      else
        raise Errno::EACCES.new(path)
    end

    return buf.length
  end

  def flush(ctx,path,fi)
    case path
      when RX_CHARACTER
	if @writebuf[path]
          Log.debug "flushing #{$1}/#{$2}"
          @handler.save_character $1, $2, @writebuf.delete(path)
        end
    end
  end

  # We ignore all xattr calls.
  def getxattr(ctx,path,name)
    return ""
  end

  # Some random numbers to show with df command
  def statfs(ctx,path)
    s = RFuse::StatVfs.new()
    s.f_bsize  = 1024
    s.f_frsize   = 1024
    s.f_blocks   = 1000000
    s.f_bfree  = 500000
    s.f_bavail   = 990000
    s.f_files  = 10000
    s.f_ffree  = 9900
    s.f_favail   = 9900
    s.f_fsid   = 23423
    s.f_flag   = 0
    s.f_namemax  = 10000
    return s
  end

  def ioctl(ctx, path, cmd, arg, ffi, flags, data)
    Log.debug "*** IOCTL: command: " + cmd
  end

  def poll(ctx, path, ffi, ph, reventsp)
    Log.debug "*** POLL: " + path
    #  # This is how we notify the caller if something happens:
    ph.notifyPoll()
  #  # when the GC harvests the object it calls fuse_pollhandle_destroy
  #  # by itself.
  end

  def init(ctx,rfuseconninfo)
  end
end
