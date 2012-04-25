class Admin::ContactCongressController < Admin::IndexController
  before_filter :admin_login_required

  def index
    @page_title = 'Contact Congress Configuration'
    @people = Person.all_sitting
  end
  
  def letters
    @page_title = 'Contact Congress Letters'
    @letters = ContactCongressLetter.order('created_at DESC').all.paginate(:per_page => 50, :page => params[:page])
  end
  
  def stats
    @page_title = 'Contact Congress Stats'
    @people = Person.all_sitting
  end
end