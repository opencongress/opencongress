require File.dirname(__FILE__) + '/../test_helper'
require 'issue_controller'

# Re-raise errors caught by the controller.
class IssueController; def rescue_action(e) raise e end; end

class IssueControllerTest < Test::Unit::TestCase
  def setup
    @controller = IssueController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @budgets = Subject.find_by_term "Budgets"
  end

  # Replace this with your real tests.
  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'by_bill_count'
  end

  def test_bill_count
    get :by_bill_count
    assert_response :success
    assert_tag :tag => "div", :attributes => {:id => "issue_list"}
  end

  def test_alphabetical
    get :alphabetical
    assert_response :redirect
    assert_redirected_to :action => 'alphabetical', :id => 'A'
  end

  def test_alphabetical_a
    get :alphabetical, :id => 'A'
    assert_tag :tag => "div", :attributes => {:id => "issue_list"}
    assert_not_nil assigns["subjects"], "No subjects"
  end

  def test_top_twenty
    get :top_twenty_bills, :id => @budgets.id
    assert_response :success
    assert_tag :tag => "div", :attributes => {:id => "related_bills_list"}
    bills = assigns["bills"]
    assert_not_nil bills, "No bills"
    assert_equal bills.size, 20, "Not twenty bills"
  end

  def test_show
    get :show, :id => @budgets.id
    assert_response :success
    assert_tag :tag => "div", :attributes => {:id => "issue_summary_text"}
    assert_tag :tag => "div", :attributes => {:id => "related_bills_list"}
    assert_tag :tag => "div", :attributes => {:id => "issue_title"}
  end

  def test_views
    orig = @budgets.views
    get :show, :id => @budgets.id
    assert_response :success
    assert @budgets.views == orig + 1, "No view logged for this hit"
  end

end
