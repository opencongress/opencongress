require File.dirname(__FILE__) + '/../test_helper'

class CommitteeReportTest < Test::Unit::TestCase

  def test_committee_report
    assert_nothing_raised { CommitteeReport.find :first }
  end

  def test_committee_report_associations
    report = CommitteeReport.find_by_title('JOB  TRAINING  IMPROVEMENT  ACT  OF  2005')
    assert_not_nil report.person, "No person"
    assert_not_nil report.bill, "No bill"
    assert_not_nil report.committee, "No committee"
    assert report.committee.reports.include?(report), "Association from committee is broken"
    assert report.bill.committee_reports.include?(report), "Bill association is broken"
    assert report.person.committee_reports.include?(report), "Person association is broken"
  end
end
