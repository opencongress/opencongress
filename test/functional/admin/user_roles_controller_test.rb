require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/user_roles_controller'

# Re-raise errors caught by the controller.
class Admin::UserRolesController; def rescue_action(e) raise e end; end

class Admin::UserRolesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::UserRolesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
