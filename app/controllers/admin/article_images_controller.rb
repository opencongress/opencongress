class Admin::ArticleImagesController < Admin::IndexController
  before_filter :can_blog
  before_filter :find_article
  before_filter :find_or_build_photo

  def create
    if @image.save
      redirect_to edit_admin_article_url(@article)
    else
      flash[:error] = 'Photo could not be uploaded'
    end
  end

  def destroy
    respond_to do |format|
      unless @image.destroy
        flash[:error] = 'Photo could not be deleted'
      end
      format.js
    end
  end

  private
    
  def find_article
    @article = Article.find(params[:article_id])
    raise ActiveRecord::RecordNotFound unless @article
  end
  
  def find_or_build_photo
    @image = params[:id] ? @article.article_images.find(params[:id]) : @article.article_images.build(params[:article_image])
  end

end
