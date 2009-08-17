require 'test_helper'

class WatchDogsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:watch_dogs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_watch_dog
    assert_difference('WatchDog.count') do
      post :create, :watch_dog => { }
    end

    assert_redirected_to watch_dog_path(assigns(:watch_dog))
  end

  def test_should_show_watch_dog
    get :show, :id => watch_dogs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => watch_dogs(:one).id
    assert_response :success
  end

  def test_should_update_watch_dog
    put :update, :id => watch_dogs(:one).id, :watch_dog => { }
    assert_redirected_to watch_dog_path(assigns(:watch_dog))
  end

  def test_should_destroy_watch_dog
    assert_difference('WatchDog.count', -1) do
      delete :destroy, :id => watch_dogs(:one).id
    end

    assert_redirected_to watch_dogs_path
  end
end
