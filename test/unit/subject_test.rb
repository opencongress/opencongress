require File.dirname(__FILE__) + '/../test_helper'

class SubjectTest < Test::Unit::TestCase

  def setup
    @roaches = Subject.find_by_term "Cockroaches"
    @congress = Subject.find_by_term "Congress"
  end

  def test_no_duplicate_subjects
    subjects = Subject.find_all
    terms = subjects.map { |s| s.term }
    assert_equal terms, terms.uniq, "Duplicate subjects"
  end

  def test_bills
    assert_nothing_raised { @roaches.bills }
    assert_instance_of Array, @roaches.bills, "Roach bills are not an array"
    assert @roaches.bills.size > 0, "No bills about roaches"
  end

  def test_latest_bills
    assert_nothing_raised { @congress.latest_bills(20) }
    bills = @congress.latest_bills(20)
    assert bills.size == 20, "Wrong number of bills"
    sorted = bills.sort_by { |b| b.lastaction }.reverse.map { |b| b.lastaction }
    assert_equal sorted, bills.map { |b| b.lastaction }, "Not ordered"
  end

  def test_congress_related
    assert_nothing_raised { @congress.related_subjects(10) }
    subjects = @congress.related_subjects(10)
    assert subjects.size == 10, "Wrong number of related subjects"
  end

  def test_congress_all_related
    assert_nothing_raised { @congress.all_related_subjects() }
    subjects = @congress.all_related_subjects()
    assert subjects.size > 10, "Wrong number of related subjects"
  end

  def test_random
    ss = nil
    assert_nothing_raised { ss = Subject.random(3) }
    assert_equal 3, ss.size, "Wrong number of subjects"
    ss.each { |b| assert_kind_of Subject, b, "Funky SQL brokenness" }
    ss.each { |b| assert_equal b, Subject.find(b.id), "Equality is busted for random subjects" }
  end


end
