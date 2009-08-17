require File.dirname(__FILE__) + '/../test_helper'

class BillTest < Test::Unit::TestCase
#  fixtures :bills

  ALL_NAMES = %w(h s hj sj hc sc hr sr)

  def setup 
    @first = Bill.find :first
  end

  def test_long_type_to_short
    assert_not_nil Bill.long_type_to_short("H. Res."), "Couldn't get type"
  end

  def test_cosponsors
    assert_nothing_raised { @first.co_sponsors }
    assert @first.co_sponsors.size > 0, "No cosponsors?"
  end

  def test_relatedbills
    assert_nothing_raised { @first.related_bills }
  end

  def test_actions
    assert_nothing_raised { @first.actions }
    assert_instance_of Array, @first.actions, "Actions is not an array"
    assert_instance_of BillAction, @first.actions[0], "Not a BillAction"
  end

  def test_lastaction
    lastaction = @first.lastaction
    action = @first.actions.max { |a,b| a.date <=>  b.date}
    assert_equal lastaction, action.date, "lastaction is not last action"
  end

  def test_committees
    assert_nothing_raised { @first.committees }
    assert_instance_of Array, @first.committees
    assert @first.committees.size > 0, "No committees for first bill"
  end
  
  def test_officialtitle
    ot = @first.officialtitle
    t = @first.bill_titles.select { |t| t.title_type == "official" }.first
    assert_equal ot, t, "official title is not official title"
  end

  def test_typename
    assert_nothing_raised{ @first.type_name}
    assert_not_nil @first.type_name, "No type name"
  end

  def test_titles
    assert_nothing_raised{ @first.bill_titles }
    assert @first.bill_titles.size > 0, "No bill titles"
  end

  def test_short_title
    short = BillTitle.find_by_title_type("short").bill
    assert_nothing_raised{ short.short_title }
    assert_not_nil short.short_title, "Short title association is broken"
  end

  def test_ident
    proper_names = ALL_NAMES.map {|pn| "#{pn}333"}
    type_names = ALL_NAMES.map do |x|
      Bill.new(:bill_type => x, :number => 333)
    end
    assert_equal type_names.map(&:ident), proper_names, "definition of proper_name has changed"
    assert_equal Bill.ident('h123j'), [nil, nil], "Illegal bill identifier permitted"
    assert_equal Bill.ident('z123'), [nil, nil], "Illegal bill identifier permitted"
    assert_equal Bill.ident('hj'), [nil, nil], "Illegal bill identifier permitted"
    assert_equal Bill.ident('222'), [nil, nil], "Illegal bill identifier permitted"
  end
  
  def test_from_param
    good_param = "234324_hr3456"
    id, type, number = Bill.from_param(good_param)
    assert_equal id, 234324, "Bad bill id number from good bill param"
    assert_equal type, 'h', "Bad bill type from good bill param"
    assert_equal number, 3456, "Bad bill number from good bill param"
    bad_param = %w{234324_hr345d3 3d334_sconres34 343_ssdd99}
    bad_param.each_with_index do |bp, i|
      id, type, number = Bill.from_param(bp)
      assert_nil id, "Good bill id number from bad bill param #{i}"
      assert_nil type, "Good bill type from bad bill param #{i}"
      assert_nil number, "Good bill number from bad bill param #{i}"
    end
  end
  
  def test_random
    bs = nil
    assert_nothing_raised { bs = Bill.random(3) }
    assert_equal 3, bs.size, "Wrong number of bills"
    bs.each { |b| assert_kind_of Bill, b, "Funky SQL brokenness" }
    bs.each { |b| assert_equal b, Bill.find(b.id), "Equality is busted for random bills" }
  end
end
