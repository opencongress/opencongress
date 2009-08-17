class BillComment < Comment
  acts_as_tree :order => "id"
end
