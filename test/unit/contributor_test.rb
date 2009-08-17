require File.dirname(__FILE__) + '/../test_helper'

class ContributorTest < Test::Unit::TestCase

  def setup
    @intel = Contributor.find_by_name("Intel Corp")
  end

  def test_contributor
    assert_nothing_raised {Contributor.find_all}
  end

  def test_intel
    assert_not_nil @intel
    assert_nothing_raised {@intel.people}
    assert !@intel.people.empty?, "Intel does not give to anybody?"
    assert_instance_of Person, @intel.people.first, "Weirdness with people" 
  end
end
