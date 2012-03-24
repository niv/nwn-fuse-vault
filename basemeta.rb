class BaseMeta 
  def get_meta_account_list account
    Log.debug(self.class.to_s) { "get_meta_account_list #{account}" }
    
    []
  end
  
  def get_meta_account_size account, meta
    Log.debug(self.class.to_s) { "get_meta_account_size #{account}, #{meta}" }
  end

  def get_meta_account_content account, meta
    Log.debug(self.class.to_s) { "get_meta_account_content #{account}, #{meta}" }
  end


  def get_meta_character_list account, character
    Log.debug(self.class.to_s) { "get_meta_character_list #{account}" }
    
    []
  end
  
  def get_meta_character_size account, character, meta
    Log.debug(self.class.to_s) { "get_meta_character_size #{account}, #{character}, #{meta}" }
  end

  def get_meta_character_content account, character, meta
    Log.debug(self.class.to_s) { "get_meta_character_content #{account}, #{character}, #{meta}" }
  end
end
