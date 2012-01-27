require File.dirname(__FILE__) + '/../test_helper'

class SubjectRelationTest < Test::Unit::TestCase
  def setup
    @armed = Subject.find_by_term "Armed forces"
  end

  # Replace this with your real tests.
  def test_armed_forces
    sr = SubjectRelation.related(@armed, 10)
    assert_not_nil sr, "No related subjects"
    assert_instance_of Array, sr, "Weird related subjects"
    assert_equal sr.length, 10, "Wrong number of related subjects"
  end

  def test_all_armed_forces
    sr = SubjectRelation.all_related(@armed)
    assert_not_nil sr, "No related subjects"
    assert_instance_of Array, sr, "Weird related subjects"
    assert sr.length > 10, "Wrong number of related subjects"
  end
end
