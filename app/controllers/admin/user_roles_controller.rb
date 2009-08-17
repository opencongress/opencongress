class Admin::UserRolesController < ApplicationController
   before_filter :admin_login_required
end
