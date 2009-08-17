class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_save(record)
    expire_fragment("article_#{record.id}")
  end
end