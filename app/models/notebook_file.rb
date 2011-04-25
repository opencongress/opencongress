class NotebookFile < NotebookItem

  # has_attachment :content_type => ['application/pdf', :image,'application/msword', 'text/plain'],     
  #   :storage => :file_system, 
  #   :max_size => 1024.kilobytes, 
  #   :resize_to => '600x>', 
  #   :thumbnails => { 
  #     :small => '48x48>',
  #     :medium => '200x>'       
  #   } 
  # 
  # validates_as_attachment 

  #validates_presence_of :url, :title
  
  def can_render_thumbnail?
    self.image?
  end
  
  def filesytem_path
    Rails.root.join("public", public_filename)
  end

  def item_div(size, item_id)
    height = NotebookFile.find(:first,
                      :conditions => ["thumbnail = ? AND parent_id = ?", size, item_id])
    return height.height
  end

end
