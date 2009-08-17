require File.dirname(__FILE__) + '/../test_helper'
require 'friends_controller'

# Re-raise errors caught by the controller.
class FriendsController; def rescue_action(e) raise e end; end

class FriendsControllerTest < Test::Unit::TestCase
  fixtures :friends

  def setup
    @controller = FriendsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:friends)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_friend
    old_count = Friend.count
    post :create, :friend => { }
    assert_equal old_count+1, Friend.count
    
    assert_redirected_to friend_path(assigns(:friend))
  end

  def test_should_show_friend
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_friend
    put :update, :id => 1, :friend => { }
    assert_redirected_to friend_path(assigns(:friend))
  end
  
  def test_should_destroy_friend
    old_count = Friend.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Friend.count
    
    assert_redirected_to friends_path
  end
end
