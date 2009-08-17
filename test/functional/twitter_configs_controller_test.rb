require 'test_helper'

class TwitterConfigsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_config" do
    assert_difference('TwitterConfig.count') do
      post :create, :twitter_config => { }
    end

    assert_redirected_to twitter_config_path(assigns(:twitter_config))
  end

  test "should show twitter_config" do
    get :show, :id => twitter_configs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => twitter_configs(:one).to_param
    assert_response :success
  end

  test "should update twitter_config" do
    put :update, :id => twitter_configs(:one).to_param, :twitter_config => { }
    assert_redirected_to twitter_config_path(assigns(:twitter_config))
  end

  test "should destroy twitter_config" do
    assert_difference('TwitterConfig.count', -1) do
      delete :destroy, :id => twitter_configs(:one).to_param
    end

    assert_redirected_to twitter_configs_path
  end
end
