class Admin::IndexController < ApplicationController
  before_filter :login_required
  before_filter :no_users

  def index
  end
  
end
