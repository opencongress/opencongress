require File.dirname(__FILE__) + '/../test_helper'

class SectorTest < Test::Unit::TestCase

  def setup
    @defense = Sector.find_by_name("Defense")
  end
  
  # Replace this with your real tests.
  def test_sector
    assert_nothing_raised { Sector.find_all}
  end

  def test_defense
    assert_nothing_raised {@defense.people}
    assert !@defense.people.empty?, "No people in the defense sector"
    assert_instance_of Person, @defense.people.first
  end
end
