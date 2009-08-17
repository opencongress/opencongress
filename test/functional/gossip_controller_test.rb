require File.dirname(__FILE__) + '/../test_helper'
require 'gossip_controller'

# Re-raise errors caught by the controller.
class GossipController; def rescue_action(e) raise e end; end

class GossipControllerTest < Test::Unit::TestCase
  def setup
    @controller = GossipController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns['gossip']
    assert assigns['gossip'].size > 0, "No gossip"
  end

  def test_submit
    get :submit
    assert_response :success
  end

  def test_blank_name_tip
    post :tip, {'tip' => {'name' => "", 'email' => "ben@matasar.org", 'link' => '', 'tip' => 'hello'}}
    assert flash[:notice].match(/Blank/)
    assert_redirected_to :controller => 'gossip', :action => 'submit'
  end

  def test_real_tip
    post :tip, {'tip' => {'name' => "ben", 'email' => "ben@matasar.org", 'link' => '', 'tip' => 'hello'}}
    assert flash[:notice].match(/Thanks/)
    assert_redirected_to :controller => 'gossip', :action => 'index'
  end
end
