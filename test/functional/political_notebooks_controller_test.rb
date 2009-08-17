require File.dirname(__FILE__) + '/../test_helper'

class PoliticalNotebooksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:political_notebooks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_political_notebook
    assert_difference('PoliticalNotebook.count') do
      post :create, :political_notebook => { }
    end

    assert_redirected_to political_notebook_path(assigns(:political_notebook))
  end

  def test_should_show_political_notebook
    get :show, :id => political_notebooks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => political_notebooks(:one).id
    assert_response :success
  end

  def test_should_update_political_notebook
    put :update, :id => political_notebooks(:one).id, :political_notebook => { }
    assert_redirected_to political_notebook_path(assigns(:political_notebook))
  end

  def test_should_destroy_political_notebook
    assert_difference('PoliticalNotebook.count', -1) do
      delete :destroy, :id => political_notebooks(:one).id
    end

    assert_redirected_to political_notebooks_path
  end
end
