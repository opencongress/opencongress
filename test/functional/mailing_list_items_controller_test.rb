require 'test_helper'

class MailingListItemsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mailing_list_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mailing_list_item" do
    assert_difference('MailingListItem.count') do
      post :create, :mailing_list_item => { }
    end

    assert_redirected_to mailing_list_item_path(assigns(:mailing_list_item))
  end

  test "should show mailing_list_item" do
    get :show, :id => mailing_list_items(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mailing_list_items(:one).to_param
    assert_response :success
  end

  test "should update mailing_list_item" do
    put :update, :id => mailing_list_items(:one).to_param, :mailing_list_item => { }
    assert_redirected_to mailing_list_item_path(assigns(:mailing_list_item))
  end

  test "should destroy mailing_list_item" do
    assert_difference('MailingListItem.count', -1) do
      delete :destroy, :id => mailing_list_items(:one).to_param
    end

    assert_redirected_to mailing_list_items_path
  end
end
