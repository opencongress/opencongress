class IndexSweeper < ActionController::Caching::Sweeper
  observe FeaturedPerson

  def after_save(record)
    expire_page("/index")
  end
end