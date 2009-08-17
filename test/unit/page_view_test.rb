require File.dirname(__FILE__) + '/../test_helper'
require 'page_view'

class PageViewTest < Test::Unit::TestCase
  
  def setup
    @bill = Bill.find :first
    @issue = Subject.find :first
    @rep = Person.representatives(109).first
    @sen = Person.senators(109).first
  end

  def test_bracket_creation
    v = nil
    assert_nothing_raised { v = BillView[:bill => @bill] }
    assert_instance_of Bill, v.bill
    assert_equal v.bill, @bill
    run_created_view_tests(v)
  end

  def test_popular_issues
    pop = nil
    assert_nothing_raised { pop = IssueView.popular 2.days }
    assert_instance_of Array, pop
    pop.each { |v| assert_instance_of Subject, v }
  end

  def test_popular_reps
    pop = nil
    assert_nothing_raised { pop = RepresentativeView.popular 2.days }
    assert_instance_of Array, pop
    pop.each { |v| assert_instance_of Person, v }
  end

  def test_popular_senators
    pop = nil
    assert_nothing_raised { pop = SenatorView.popular 2.days }
    assert_instance_of Array, pop
    pop.each { |v| assert_instance_of Person, v }
  end

  def test_popular_bills
    pop = nil
    assert_nothing_raised { pop = BillView.popular 2.days }
    assert_instance_of Array, pop
    pop.each { |v| assert_instance_of Bill, v }
  end

  def test_bill_view
    v = nil
    assert_nothing_raised { v =  BillView.create({:bill => @bill}) }
    assert_instance_of Bill, v.bill
    assert_equal v.bill, @bill
    run_created_view_tests(v)
  end

  def test_issue_view
    v = nil
    assert_nothing_raised { v =  IssueView.create({:subject => @issue}) }
    assert_instance_of Subject, v.subject
    assert_equal v.subject, @issue
    run_created_view_tests(v)
  end

  def test_representative_view
    v = nil
    assert_nothing_raised { v =  RepresentativeView.create({:person => @rep}) }
    assert_instance_of Person, v.person
    assert_equal v.person, @rep
    run_created_view_tests(v)
  end

  def test_senator_view
    v = nil
    assert_nothing_raised { v = SenatorView.create({:person => @sen}) }
    assert_instance_of Person, v.person
    assert_equal v.person, @sen
    run_created_view_tests(v)
  end

  private
  def run_created_view_tests(view)
    assert_not_nil view.created_at, "No created at field"
    assert view.created_at > 1.day.ago, "Weirdness with times #{view.created_at} - 1."
    assert view.created_at <= Time.new, "Weirdness with times #{view.created_at} - 2."
  end
end
