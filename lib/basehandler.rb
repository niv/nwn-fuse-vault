class BaseHandler
  # Return a list of accounts with characters in their vault.
  # Example: ["_-boromir_love-_", "Legolas13"]
  def get_account_list
  end

  # Returns a list of character identifiers a account has, WITHOUT EXTENSION.
  # You are free to name them as you wish, but nwserver will refer to them
  # with that name while the player is online so beware.
  # Example: ['nobby', 'vimes']
  def get_character_list account
  end

  # Returns the size of a character in bytes. filename is once again WITHOUT EXTENSION.
  # Example: 123456
  def get_character_size account, filename
  end

  # Reads a character and returns it's contents as a BINARY string.
  # filename is without extension.
  def load_character account, filename
  end

  # Saves a character to the vault.
  # filename is without extension.
  # Returns nothing.
  def save_character account, filename, data
  end
end
