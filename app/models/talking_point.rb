class TalkingPoint < ActiveRecord::Base
  belongs_to :talking_pointable, :polymorphic => true
end
