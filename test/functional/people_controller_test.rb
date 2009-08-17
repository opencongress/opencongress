require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < Test::Unit::TestCase
  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @reps = Person.representatives(109)
    @senators = Person.senators(109)
    @earl = Person.find_by_lastname("Blumenauer") #rep
    @barbara = Person.find_by_lastname("Boxer") #senator
  end
  
  def test_representatives
    get :representative_list
    assert_response :success
    reps = assigns["representatives"]
    assert_not_nil reps, "No reps?"
    assert_equal reps.length, @reps.length
  end

  def test_senators
    get :senator_list
    assert_response :success
    senators = assigns["senators"]
    assert_not_nil senators, "No senators?"
    assert_equal senators.length, @senators.length
  end

  def test_earl
    orig = @earl.views
    last = RepresentativeView.find_all.last
    get :show, :id => @earl.id
    earl_hit = RepresentativeView.find_all.last
    assert_not_same last, earl_hit
    assert_equal @earl, earl_hit.person
    assert (orig + 1) == @earl.views, "View not logged"
  end

  def test_barbara
    orig = @barbara.views
    last = SenatorView.find_all.last
    get :show, :id => @barbara.id
    barb_hit = SenatorView.find_all.last
    assert_not_same last, barb_hit
    assert_equal @barbara, barb_hit.person
    assert orig + 1 == @barbara.views, "View not logged"
  end
end
