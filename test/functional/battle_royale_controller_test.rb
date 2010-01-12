require File.dirname(__FILE__) + '/../test_helper'
require 'battle_royale_controller'

# Re-raise errors caught by the controller.
class BattleRoyaleController; def rescue_action(e) raise e end; end

class BattleRoyaleControllerTest < Test::Unit::TestCase
  def setup
    @controller = BattleRoyaleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
