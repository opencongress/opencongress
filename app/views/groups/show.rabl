object @group

extends "groups/group"

child(:group_bill_positions) do
  attributes :position
  child(:bill) do
    extends "bill/show"
  end
end
