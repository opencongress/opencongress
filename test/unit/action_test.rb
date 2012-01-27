require File.dirname(__FILE__) + '/../test_helper'

class ActionTest < Test::Unit::TestCase

  # Replace this with your real tests.
  def test_amendment_action
    aa = Action.find(:first, :conditions => ["type = 'AmendmentAction'"])
    assert_instance_of AmendmentAction, aa
  end

  def test_bill_action
    ba = Action.find(:first, :conditions => ["type = 'BillAction'"])
    assert_instance_of BillAction, ba
  end
end
