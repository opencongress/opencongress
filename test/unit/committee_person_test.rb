require File.dirname(__FILE__) + '/../test_helper'

class CommitteePersonTest < Test::Unit::TestCase
#  fixtures :committee_people

  def setup
    @earl = Person.find_by_lastname "Blumenauer"
  end

  # Replace this with your real tests.
  def test_committee_person
    assert_instance_of Array, @earl.committees
    assert @earl.committees.length > 0, "Earl has no committees"
  end
end
