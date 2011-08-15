class Admin::ContactCongressController < Admin::IndexController
  before_filter :admin_login_required

  def index
    @page_title = 'Contact Congress Configuration'
    @people = Person.where("title IS NOT NULL").order("title ASC, page_views_count DESC").all
  end
  
  def letters
    @page_title = 'Contact Congress Letters'
    @letters = ContactCongressLetter.order('created_at DESC').all.paginate(:per_page => 50, :page => params[:page])
  end
end