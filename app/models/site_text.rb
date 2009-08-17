class SiteText < ActiveRecord::Base
  def self.find_by_type(text_type)
    st = self.find(:first, :conditions => [ "text_type = ?", text_type])
    
    st ? st.text : nil
  end
  
  def self.find_title_desc(tag)
    self.find_by_type("#{tag}:title_desc")
  end

  def self.find_dropdown_text(tag)
    self.find_by_type("#{tag}:dropdown_text")
  end
  
  def self.find_explain(tag)
    self.find_by_type("#{tag}:explain")
  end

  def self.find_plaintext(tag)
    self.find_by_type("#{tag}:plaintext")
  end
end
