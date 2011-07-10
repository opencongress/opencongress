class PoliticalNotebook < ActiveRecord::Base
  belongs_to :user  
  belongs_to :group
  
  has_many :notebook_items, :order => 'created_at DESC' #sti, all

  has_many :notebook_links
  has_many :notebook_videos    
  has_many :notebook_notes    
  has_many :notebook_files
  
  def atom_id
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/political_notebook/#{id}"
  end
  
  def self.find_or_create_from_user(user)
    if user.political_notebook.blank?
      pn = PoliticalNotebook.new
      pn.user_id = user.id
      pn.save
      pn
    else
      user.political_notebook
    end
  end
  
  def self.find_or_create_from_group(group)
    if group.political_notebook.blank?
      pn = PoliticalNotebook.new
      pn.group_id = group.id
      pn.save
      pn
    else
      group.political_notebook
    end
  end

  def already_contains?(object)
    self.notebook_links.count(:conditions =>["notebook_items.notebookable_id = ? and notebook_items.notebookable_type = ?", object.id, object.class.to_s]) > 0
  end  
  
  def can_view?(viewer)
    if self.group.nil?
      return self.user.can_view('my_political_notebook',viewer)    
    else
      return ((self.group.join_type != 'INVITE_ONLY') && self.group.is_member?(viewer))
    end
  end
  
  def can_edit?(editor)
    return false if (editor == :false)
    if self.group.nil?
      return PoliticalNotebook.find_or_create_from_user(editor) === self
    else
      return self.group.can_post?(editor)
    end
  end
end
