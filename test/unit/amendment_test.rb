require File.dirname(__FILE__) + '/../test_helper'

class AmendmentTest < Test::Unit::TestCase
  #fixtures :amendments
  def setup
    @first = Amendment.find :first
  end

  # Replace this with your real tests.
  def test_bill
    assert_nothing_raised {@first.bill}
    assert_instance_of Bill, @first.bill, "Bill is not bill"
  end

  def test_action
    aa = AmendmentAction.find :first
    assert_nothing_raised {aa.amendment.actions}
    assert_instance_of AmendmentAction, aa.amendment.actions[0], "Wrong type for amendment actions."
  end
end
