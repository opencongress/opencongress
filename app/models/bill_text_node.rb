class BillTextNode < ActiveRecord::Base
  belongs_to :bill_text_version

  has_many :comments, :as => :commentable
  
  attr_accessor :bill_text_cache
  
  def display_object_name
    "Bill Text"
  end

  def ident
   "#{self.bill_text_version_id}-#{self.nid}"
  end

  def paragraph_number
    stuff = nid.split(/:/)
    stuff[2]
  end
  
  def bill_text
    return @bill_text_cache unless @bill_text_cache.nil?
    
    path = "#{Settings.oc_billtext_path}/#{bill_text_version.bill.session}/#{bill_text_version.bill.bill_type}#{bill_text_version.bill.number}#{bill_text_version.version}.gen.html-oc"
    
    begin
      doc = Nokogiri::XML(open(path))    
      node = doc.css("p[@id='bill_text_section_#{nid}']")
    
      @bill_text_cache = node.text.gsub(/CommentsClose CommentsPermalink/, "")
    rescue
      return ""
    end
  end
end
