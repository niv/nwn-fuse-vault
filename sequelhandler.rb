require 'rubygems'
require 'sequel'

class SequelHandler < BaseHandler
  DB = Sequel.connect($config['database'])
  Vault = DB[:vault]

  def get_account_list
    Log.debug("sequel") { "get_account_list" }

    Vault.distinct.select(:account).all.map do |p|
      p[:account]
    end
  end

  def get_character_list account
    Log.debug("sequel") { "get_character_list: #{account}" }

    Vault.
      filter(:account => account).
      select(:filename).
      all.map do |p|
        p[:filename]
      end
  end

  def get_character_size account, filename
    Log.debug("sequel") { "get_character_size: #{account}, #{filename}" }

    char = Vault.
      filter(:account => account, :filename => filename).
      select { length(:data) }.
      first

    char[:length]
  end

  def load_character account, filename
    Log.debug("sequel") { "load_character: #{account}, #{filename}" }

    char = Vault.
      filter(:account => account, :filename => filename).
      select(:data).
      first

    char[:data]
  end

  def save_character account, filename, data
    Log.debug("sequel") { "save_character: #{account}, #{filename}, #{data.size} bytes" }

    q = Vault.filter(:account => account, :filename => filename)

    if q.count == 1
      q.update(
        :updated_on => Time.now,
        :data => data.to_sequel_blob
      )

    else
      Vault.insert({
        :account => account,
        :filename => filename,
        :data => data.to_sequel_blob
      })
    end
  end

  def delete_character account, filename
    Log.debug("sequel") { "delete_character: #{account}, #{filename}" }

    Vault.filter(:account => account, :filename => filename).delete
  end
end
