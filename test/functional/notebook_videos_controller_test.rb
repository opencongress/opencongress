require File.dirname(__FILE__) + '/../test_helper'

class NotebookVideosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:notebook_videos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_notebook_video
    assert_difference('NotebookVideo.count') do
      post :create, :notebook_video => { }
    end

    assert_redirected_to notebook_video_path(assigns(:notebook_video))
  end

  def test_should_show_notebook_video
    get :show, :id => notebook_videos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => notebook_videos(:one).id
    assert_response :success
  end

  def test_should_update_notebook_video
    put :update, :id => notebook_videos(:one).id, :notebook_video => { }
    assert_redirected_to notebook_video_path(assigns(:notebook_video))
  end

  def test_should_destroy_notebook_video
    assert_difference('NotebookVideo.count', -1) do
      delete :destroy, :id => notebook_videos(:one).id
    end

    assert_redirected_to notebook_videos_path
  end
end
