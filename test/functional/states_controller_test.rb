require 'test_helper'

class StatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:states)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_state
    assert_difference('State.count') do
      post :create, :state => { }
    end

    assert_redirected_to state_path(assigns(:state))
  end

  def test_should_show_state
    get :show, :id => states(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => states(:one).id
    assert_response :success
  end

  def test_should_update_state
    put :update, :id => states(:one).id, :state => { }
    assert_redirected_to state_path(assigns(:state))
  end

  def test_should_destroy_state
    assert_difference('State.count', -1) do
      delete :destroy, :id => states(:one).id
    end

    assert_redirected_to states_path
  end
end
