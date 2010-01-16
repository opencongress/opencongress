class CommentaryController < ApplicationController
  skip_before_filter :store_location, :only => [:rate]

  def rate
    unless current_user == :false
      commentary = Commentary.find_by_id(params[:id])
      score = current_user.commentary_ratings.find_or_initialize_by_commentary_id(commentary.id)
      score.rating = params[:value]
      score.save

      if commentary.commentary_ratings.length >= 3
        commentary.average_rating = commentary.commentary_ratings.average(:rating)
        commentary.save
      end
      
      #commentary.commentariable.expire_commentary_fragments(commentary.is_news? ? 'news' : 'blog')
      
      logger.info params.to_yaml
      render :text => "<font style='color:#45A307;'>Saved.</font>"
    else
      render :text => "<font style='color:#45A307;'>You must be logged in to rate articles. Log in above.</font>"
    end
  end
  
  def pn_ajax_multiple
    logger.warn "object_ids #{params[:object_ids]}"

    commentary_ids = params[:object_ids].split(",")
    @commentaries = Commentary.find(:all, :conditions => ["id IN (?)", commentary_ids])
    respond_to do |format|
      format.js
    end   
  end
end
