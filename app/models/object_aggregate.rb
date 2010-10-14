class ObjectAggregate < ActiveRecord::Base
  belongs_to :aggregatable, :polymorphic => true
end