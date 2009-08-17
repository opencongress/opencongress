require 'test_helper'

class UserMailingListsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_mailing_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_mailing_list" do
    assert_difference('UserMailingList.count') do
      post :create, :user_mailing_list => { }
    end

    assert_redirected_to user_mailing_list_path(assigns(:user_mailing_list))
  end

  test "should show user_mailing_list" do
    get :show, :id => user_mailing_lists(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user_mailing_lists(:one).to_param
    assert_response :success
  end

  test "should update user_mailing_list" do
    put :update, :id => user_mailing_lists(:one).to_param, :user_mailing_list => { }
    assert_redirected_to user_mailing_list_path(assigns(:user_mailing_list))
  end

  test "should destroy user_mailing_list" do
    assert_difference('UserMailingList.count', -1) do
      delete :destroy, :id => user_mailing_lists(:one).to_param
    end

    assert_redirected_to user_mailing_lists_path
  end
end
