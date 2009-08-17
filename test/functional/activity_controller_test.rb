require File.dirname(__FILE__) + '/../test_helper'
require 'activity_controller'

# Re-raise errors caught by the controller.
class ActivityController; def rescue_action(e) raise e end; end

class ActivityControllerTest < Test::Unit::TestCase
  def setup
    @controller = ActivityController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
