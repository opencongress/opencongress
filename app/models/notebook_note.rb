class NotebookNote < NotebookItem
  
  
  validates_presence_of :description
  
  # because the table uses STI a regular polymorphic association doesn't work
  has_many :comments, :foreign_key => 'commentable_id', :conditions => "commentable_type='NotebookNote'"
end
