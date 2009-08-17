class Refer < ActiveRecord::Base
  validates_uniqueness_of :ref
  belongs_to :action

  def to_s
    self.label.capitalize 
  end
end
