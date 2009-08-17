class BlogEntry < ActiveRecord::Base
    has_many :blog_comments
    has_and_belongs_to_many :profiles
end
