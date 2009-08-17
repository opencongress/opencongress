class Role < ActiveRecord::Base
  belongs_to :person
  
  @@TYPES = {
    'sen' => 'Senator',
    'rep' => 'Representative'
  }
  
  def display_type
    @@TYPES[role_type]
  end
end
