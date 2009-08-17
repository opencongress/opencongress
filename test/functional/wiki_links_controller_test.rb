require 'test_helper'

class WikiLinksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:wiki_links)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_wiki_link
    assert_difference('WikiLink.count') do
      post :create, :wiki_link => { }
    end

    assert_redirected_to wiki_link_path(assigns(:wiki_link))
  end

  def test_should_show_wiki_link
    get :show, :id => wiki_links(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => wiki_links(:one).id
    assert_response :success
  end

  def test_should_update_wiki_link
    put :update, :id => wiki_links(:one).id, :wiki_link => { }
    assert_redirected_to wiki_link_path(assigns(:wiki_link))
  end

  def test_should_destroy_wiki_link
    assert_difference('WikiLink.count', -1) do
      delete :destroy, :id => wiki_links(:one).id
    end

    assert_redirected_to wiki_links_path
  end
end
