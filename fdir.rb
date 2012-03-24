class ServerVaultDirHandler < FuseFS::FuseDir
  RX_ACCOUNT   = %r{^/([^/]+)$}
  RX_CHARACTER = %r{^/([^/]+?)/(.+?\.bic)$}
  RX_ACC_META  = %r{^/([^/]+?)/(.+?)\.meta$}
  RX_CHR_META  = %r{^/([^/]+?)/(.+?\.bic)\.(.+?)\.bicmeta$}

  def initialize handler, meta
    @handler = handler
    @meta = meta
    @mkdir_cache = {}
  end

  def clear_cache
    @mkdir_cache.reject! {|k,v|
      Time.now - v > 10
    }
  end

  def contents path
    clear_cache

    case path
      when "/"
        if $config['allow-account-list']
          @handler.get_account_list
        else
          []
        end

      when RX_ACCOUNT
        cl = @handler.get_character_list($1)
        cl + @meta.inject([]) {|i, m|
            i + m.get_meta_account_list($1).map {|n| n + ".meta" } +
              cl.inject([]) {|k, c|
                k + m.get_meta_character_list($1, c).map {|nn| c + "." + nn + ".bicmeta" }
              }
          }
      else
        Log.error("fdir.contents") { "unhandled path: #{path.inspect}" }
        []
    end
  end

  def directory? path
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
    path =~ RX_CHARACTER ||
      path =~ RX_ACC_META ||
      path =~ RX_CHR_META
  end

  def executable? path
    false
  end

  def find_account_meta(account, file)
    @meta.select {|m| m.get_meta_account_list(account).index(file) }[0]
  end
  def find_character_meta(account, character, file)
    @meta.select {|m| m.get_meta_character_list(account, character).index(file) }[0]
  end

  def size path
    case path
      when RX_CHARACTER
        @handler.get_character_size($1, $2)

      when RX_ACC_META
        find_account_meta($1, $2).get_meta_account_size($1, $2)
      
      when RX_CHR_META
        find_character_meta($1, $2, $3).get_meta_character_size($1, $2, $3)

      else
        Log.error("fdir.size") { "unhandled path: #{path}" }
        return 0
    end
  end

  def read_file path
    case path
      when RX_CHARACTER
        @handler.load_character($1, $2)

      when RX_ACC_META
        find_account_meta($1, $2).get_meta_account_content($1, $2)
      
      when RX_CHR_META
        find_character_meta($1, $2, $3).get_meta_character_content($1, $2, $3)

      else
        Log.error("fdir.size") { "unhandled path: #{path}" }
        return nil
    end
  end

  def can_mkdir? path
    !READONLY && path =~ RX_ACCOUNT
  end
  def can_rmdir? path
    !READONLY && path =~ RX_ACCOUNT
  end
  def can_write? path
    !READONLY && path =~ RX_CHARACTER
  end
  def can_delete? path
    !READONLY && path =~ RX_CHARACTER
  end

  def mkdir path
    READONLY and begin
      Log.warn("fdir.mkdir") { "ignoring due to RO: #{path}" }
      return
    end

    path =~ RX_ACCOUNT or begin
      Log.error("fdir.mkdir") { "unhandled path: #{path}" }
      return
    end
    @mkdir_cache[$1] = Time.now
  end

  def write_to path, data
    # nwserver truncates files immediately before writing the new data.
    # We ignore that here.
    return if data.size == 0

    READONLY and begin
      Log.warn("fdir.write_to") { "ignoring due to RO: #{path}" }
      return
    end

    path =~ RX_CHARACTER or begin
      Log.error("fdir.write_to") { "unhandled path: #{path}" }
      return
    end

    @handler.save_character($1, $2, data)
  end

  def rmdir path
    READONLY and begin
      Log.warn("fdir.rmdir") { "ignoring due to RO: #{path}" }
      return
    end

    path =~ RX_ACCOUNT or return
    @mkdir_cache.delete($1)
  end

  def delete path
    READONLY and begin
      Log.warn("fdir.delete") { "ignoring due to RO: #{path}" }
      return
    end

    path =~ RX_CHARACTER or begin
      Log.error("fdir.delete") { "unhandled path: #{path}" }
      return
    end

    @handler.delete_character($1, $2)
  end
end
