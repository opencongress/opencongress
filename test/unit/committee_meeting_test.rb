require File.dirname(__FILE__) + '/../test_helper'

class CommitteeMeetingTest < Test::Unit::TestCase

  def test_committee_meeting
    assert_nothing_raised {CommitteeMeeting.find :first}
  end
end
