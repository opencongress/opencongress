object @group

extends "groups/group"

child(:group_bill_positions => :bill_positions) do
  attributes :position, :created_at
  child(:bill) do
    extends "bill/show"
  end
end
