class Admin::ContactCongressController < Admin::IndexController
  before_filter :admin_login_required

  def index
    @people = Person.where("title IS NOT NULL").order("title ASC, page_views_count DESC").all
  end
end