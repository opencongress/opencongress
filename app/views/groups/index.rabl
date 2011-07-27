object false

child (@groups => :groups) do
  extends "groups/group"
end

code(:total_pages) { @groups.total_pages }
