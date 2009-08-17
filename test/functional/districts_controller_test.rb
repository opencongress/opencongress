require 'test_helper'

class DistrictsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:districts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_district
    assert_difference('District.count') do
      post :create, :district => { }
    end

    assert_redirected_to district_path(assigns(:district))
  end

  def test_should_show_district
    get :show, :id => districts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => districts(:one).id
    assert_response :success
  end

  def test_should_update_district
    put :update, :id => districts(:one).id, :district => { }
    assert_redirected_to district_path(assigns(:district))
  end

  def test_should_destroy_district
    assert_difference('District.count', -1) do
      delete :destroy, :id => districts(:one).id
    end

    assert_redirected_to districts_path
  end
end
