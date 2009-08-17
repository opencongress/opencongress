require File.dirname(__FILE__) + '/../test_helper'
require 'bill_controller'

# Re-raise errors caught by the controller.
class BillController; def rescue_action(e) raise e end; end

class BillControllerTest < Test::Unit::TestCase
  def setup
    @controller = BillController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @bill = Bill.find_by_bill_type_and_number("s", 3741)
  end

  def test_all
    get :all
    assert_response :success
    assert_not_nil assigns['bills']
  end

  # Replace this with your real tests.
  def test_views
    views = @bill.views
    get :show, :id => @bill.ident
    assert_response :success
    assert_not_nil assigns["bill"], "No bill assigned for id"
    assert_equal(views + 1, @bill.views, "No logged view")
  end

  def test_s3534
    b = Bill.find_by_bill_type_and_number("s", "3534")
    assert_not_nil b, "Couldn't find the bill"
    get :show, :id => b.ident
    assert_response :success
    assert_equal assigns["bill"], b
  end
  
  def test_send_sponsor
    num_deliveries = ActionMailer::Base.deliveries.size
    @bill.sponsor.email = "tyc@opencongress.org" unless @bill.sponsor.email
    @bill.sponsor.save
    post :send_sponsor, :id => @bill.id, :subject => "About a bill",
      :msg => "text"
    assert_response :redirect
    assert_redirected_to(:action => :show, :id => @bill.ident)
    assert_equal num_deliveries+1, ActionMailer::Base.deliveries.size
  end
end
