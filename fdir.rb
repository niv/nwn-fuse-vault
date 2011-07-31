class ServerVaultDirHandler < FuseFS::FuseDir
  RX_ACCOUNT = %r{^/([^/]+)$}
  RX_CHARACTER = %r{^/([^/]+?)/(.+?\.bic)$}

  def initialize handler
    @handler = handler
    @mkdir_cache = {}
  end

  def clear_cache
    @mkdir_cache.reject! {|k,v|
      Time.now - v > 10
    }
  end

  def contents path
    Log.debug "contents(#{path.inspect})"
    clear_cache

    case path
      when "/"
        @handler.get_account_list + @mkdir_cache.keys

      when RX_ACCOUNT
        @handler.get_character_list($1)

      else
        []
      end
  end

  def directory? path
    Log.debug "directory?(#{path.inspect})"

    case path
      when "/"
        true

      when RX_ACCOUNT
        @mkdir_cache[$1] != nil ||
          @handler.get_character_list($1).size > 0

      else
        false
      end
  end

  def file? path
    Log.debug "file?(#{path.inspect})"

    path =~ RX_CHARACTER
  end

  def executable? path
    Log.debug { "executable(#{path.inspect})" }
    false
  end

  def size path
    Log.debug "size(#{path.inspect})"

    path =~ RX_CHARACTER or return 0

    @handler.get_character_size($1, $2)
  end

  def read_file path
    Log.info { "read_file(#{path.inspect})" }

    path =~ RX_CHARACTER or return nil

    @handler.load_character($1, $2)
  end

  def can_mkdir? path
    Log.debug { "can_mkdir?(#{path.inspect})" }
    path =~ RX_ACCOUNT
  end
  def can_rmdir? path
    Log.debug { "can_rmdir?(#{path.inspect})" }
    path =~ RX_ACCOUNT
  end
  def can_write? path
    Log.debug { "can_write?(#{path.inspect})" }
    path =~ RX_CHARACTER
  end
  def can_delete? path
    Log.debug { "can_delete?(#{path.inspect})" }
    path =~ RX_CHARACTER
  end

  def mkdir path
    Log.debug { "mkdir(#{path.inspect})" }
    path =~ RX_ACCOUNT or return
    @mkdir_cache[$1] = Time.now
  end

  def write_to path, data
    # nwserver truncates files immediately before writing the new data.
    # We ignore that here.
    return if data.size == 0

    Log.info { "write_to(#{path.inspect}, sz = #{data.size})" }

    path =~ RX_CHARACTER or return

    @handler.save_character($1, $2, data)
  end

  def rmdir path
    Log.debug { "rmdir(#{path.inspect})" }
    # No action needed
  end
  def delete path
    Log.debug { "delete(#{path.inspect})" }
    path =~ RX_CHARACTER or return
    @handler.delete_character($1, $2)
  end

  def touch path
    Log.debug { "touch(#{path.inspect})" }
  end
end
