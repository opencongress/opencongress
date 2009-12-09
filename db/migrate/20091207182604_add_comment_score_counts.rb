class AddCommentScoreCounts < ActiveRecord::Migration
  def self.up
    add_column :comments, :plus_score_count, :integer, :default => 0, :null => false
    add_column :comments, :minus_score_count, :integer, :default => 0, :null => false
    
    comments = Comment.find_by_sql("SELECT comments.*, m_scores.minus_score_count AS m_count, p_scores.plus_score_count AS p_count FROM comments
        	INNER JOIN (SELECT comment_scores.comment_id AS c_id 
        	FROM comment_scores
        	GROUP BY comment_scores.comment_id) score_count
        ON comments.id=c_id
        	LEFT OUTER JOIN (SELECT comment_scores.comment_id as c_id2, count(comment_scores.id) AS plus_score_count
        	FROM comment_scores
        	WHERE comment_scores.score > 5
        	GROUP BY comment_scores.comment_id) p_scores
        ON comments.id=c_id2
    	LEFT OUTER JOIN (SELECT comment_scores.comment_id as c_id3, count(comment_scores.id) AS minus_score_count
        	FROM comment_scores
        	WHERE comment_scores.score < 5
        	GROUP BY comment_scores.comment_id) m_scores
        ON comments.id=c_id3")
    comments.each do |comment|
      if comment.m_count
        comment.minus_score_count = comment.m_count
      end
      if comment.p_count
        comment.plus_score_count = comment.p_count
      end
      comment.save
    end
  end

  def self.down
    remove_column :comments, :plus_score_count
    remove_column :comments, :minus_score_count
  end
end