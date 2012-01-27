require File.dirname(__FILE__) + '/../test_helper'

class BillRelationTest < Test::Unit::TestCase

  # Replace this with your real tests.
  def test_related_bills_field
    br = BillRelation.find(:first, :conditions => ["bill_id is not null"])
    bill = br.bill
    assert_not_nil bill, "Nil bill"
    assert !bill.related_bills.empty?, "Empty related bills for non nil associated bill"
  end

end
