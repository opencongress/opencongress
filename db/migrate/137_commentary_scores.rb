class CommentaryScores < ActiveRecord::Migration
  def self.up
    add_column :commentaries, :average_rating, :float
    
    ratings = CommentaryRating.find_by_sql("select commentary_id, count(commentary_id) as cnt from commentary_ratings group by commentary_id order by cnt desc;")
    ratings.each do |r|
      if r.cnt.to_i > 2
        r.commentary.average_rating = r.commentary.commentary_ratings.average(:rating)
        r.commentary.save
      end
    end
  end

  def self.down
    remove_column :commentaries, :average_rating
  end
end
