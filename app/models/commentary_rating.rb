class CommentaryRating < ActiveRecord::Base

  belongs_to :commentary
  belongs_to :user

end
