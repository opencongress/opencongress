require File.dirname(__FILE__) + '/../test_helper'

class CommitteeMeetingsBillTest < Test::Unit::TestCase

  def test_commitee_meetings_bills
    assert_nothing_raised { CommitteeMeetingsBill.find :all }
    cmb = CommitteeMeetingsBill.find :first
    assert_nothing_raised { cmb.bill }
    assert_nothing_raised { cmb.committee_meeting }
    assert_not_nil cmb.bill, "No bill"
    assert_not_nil cmb.committee_meeting, "No meeting"
  end

end
