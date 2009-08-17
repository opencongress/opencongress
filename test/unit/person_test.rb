require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
#  fixtures :people

  def setup
    #Earl is my representative - Ben(jamin).
    @earl = Person.find_by_firstname_and_lastname("Earl", "Blumenauer")
  end

  def test_money
    assert_nothing_raised {@earl.sectors}
    assert(@earl.sectors.size > 0, "Earl has no contributing sectors?")
    assert_instance_of Contributor, @earl.top_contributor, "Earl's top contributor is not a Contributor"
    assert @earl.money_raised > 0, "Earl hasn't raised any money!"
    assert_not_nil @earl.top_contributor_at, "No date for earl's top contributor"
    assert_not_nil @earl.money_raised_at, "No date for earl's total money raised"
  end

  def test_earl_sponsored_bills
    assert_instance_of Array, @earl.bills, "Bill association is wonky"
    assert @earl.bills.size > 0, "Earl has no bills"
  end

  def test_earl_rep_sen
    assert !@earl.senator?(109)
    assert @earl.representative?(109)
  end

  def test_congress
    assert @earl.congress?(109)
  end

  def test_earl_cosponsored_bills
    assert_nothing_raised { @earl.bills_cosponsored }
    assert_instance_of Array, @earl.bills_cosponsored, "Testing associations"
    assert @earl.bills_cosponsored.size > 0, "Earl has no cosponsored bills"
  end

  def test_earL_committees 
    #As of sept 4, we don't have committee/people associations
    assert_nothing_raised { @earl.committees }
    assert_instance_of Array, @earl.committees, "Committees are odd"
  end

  def test_representatives
    reps = Person.representatives(109)
    assert_not_nil reps
    assert reps.length > 400
  end

  def test_senators
    senators = Person.senators(109)
    assert_not_nil senators
    assert_equal 100, senators.length, "Wrong number of senators"
  end

  def test_random
    peeps = nil
    assert_nothing_raised { peeps = Person.random("rep", 3, 109) } #random three people from a given congress
    assert_not_nil peeps, "No random people"
    assert peeps.size == 3, "Why not three people?"
    peeps.each { |p| assert_kind_of Person, p, "Weird SQL happening" }
    peeps.each { |p| assert p.congress?(109) }
    assert_equal peeps[0], Person.find(peeps[0].id), "Weird SQL mojo happening"
    assert_nothing_raised { peeps = Person.random("sen", 3, 109) } #random three people from a given congress
  end
end
