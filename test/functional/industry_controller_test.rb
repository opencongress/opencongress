require File.dirname(__FILE__) + '/../test_helper'
require 'industry_controller'

# Re-raise errors caught by the controller.
class IndustryController; def rescue_action(e) raise e end; end

class IndustryControllerTest < Test::Unit::TestCase
  def setup
    @controller = IndustryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
