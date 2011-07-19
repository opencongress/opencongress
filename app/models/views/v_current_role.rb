class VCurrentRole < View
  set_primary_key :role_id
  belongs_to :state
  belongs_to :role
  belongs_to :person
end
