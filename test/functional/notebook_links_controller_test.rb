require File.dirname(__FILE__) + '/../test_helper'

class NotebookLinksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:notebook_links)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_notebook_link
    assert_difference('NotebookLink.count') do
      post :create, :notebook_link => { }
    end

    assert_redirected_to notebook_link_path(assigns(:notebook_link))
  end

  def test_should_show_notebook_link
    get :show, :id => notebook_links(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => notebook_links(:one).id
    assert_response :success
  end

  def test_should_update_notebook_link
    put :update, :id => notebook_links(:one).id, :notebook_link => { }
    assert_redirected_to notebook_link_path(assigns(:notebook_link))
  end

  def test_should_destroy_notebook_link
    assert_difference('NotebookLink.count', -1) do
      delete :destroy, :id => notebook_links(:one).id
    end

    assert_redirected_to notebook_links_path
  end
end
