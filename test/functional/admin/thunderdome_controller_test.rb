require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/thunderdome_controller'

# Re-raise errors caught by the controller.
class Admin::ThunderdomeController; def rescue_action(e) raise e end; end

class Admin::ThunderdomeControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ThunderdomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
