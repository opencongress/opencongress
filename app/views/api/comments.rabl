object false

child (@comments => :comments) do
  attributes :comment, :average_rating, :plus_score_count, :minus_score_count, :created_at, :root_id, :lft, :id

  child(:user => :author) do
    attributes :login, :main_picture, :small_picture, :id
    attributes :created_at => :joined_at
    code(:permalink) { |u| user_profile_path(:login => u.login) }
  end
end

code(:total_pages) { @comments.total_pages }
