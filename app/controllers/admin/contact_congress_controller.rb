class Admin::ContactCongressController < Admin::IndexController
  before_filter :admin_login_required

  def index
    @people = Person.all_sitting
  end
end