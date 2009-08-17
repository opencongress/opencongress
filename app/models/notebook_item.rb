class NotebookItem < ActiveRecord::Base
  acts_as_taggable_on :tags
#  alias tag_list= tag_with  

  belongs_to :political_notebook
  belongs_to :notebookable, :polymorphic => true  
  belongs_to :bill, :foreign_key => "notebookable_id", :conditions => ["notebookable_type = ?", "Bill"]  
  belongs_to :hot_bill_category
  
  # by default, returns zero; to be overridden by child classes
  def count_times_bookmarked
    return 0
  end
  
  # by default, returns empty array; to be overridden by child classes
  def other_users_bookmarked
    return []
  end
  
  def atom_id
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/political_notebook_item/#{id}"
  end
  
  def type_in_words
    type.to_s.gsub('Notebook', '')
  end
  
end
