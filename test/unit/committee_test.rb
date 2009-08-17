require File.dirname(__FILE__) + '/../test_helper'

class CommitteeTest < Test::Unit::TestCase
#  fixtures :committees

  def setup
    @first = Committee.find :first
    @standards = Committee.find(:first, :conditions => ["lower(name) = 'house standards of official conduct'"])
    @waysandmeans = Committee.find(:first, :conditions => ["lower(name) = 'house ways and means' and subcommittee_name is null"])
    @government_reform = Committee.find(:first, :conditions => ["lower(name) = 'house government reform' and subcommittee_name is null"])
    @relations = Committee.find(:first, :conditions => ["lower(name) = 'senate foreign relations' and subcommittee_name is null"])
    @davis = Person.find(400098) 
    @shays = Person.find(400370) 
    @biden = Person.find_by_lastname "Biden" 
  end

  def test_committee_meetings
    cm = CommitteeMeeting.find :first
    comm = cm.committee
    assert comm.meetings.include?(cm), "Committee meeting association is funky"
  end

  def test_no_duplicate_committees
    comms = Committee.find(:all)
    thing = comms.map { |c| [c.name,c.subcommittee_name] }
    assert_equal [], (thing - thing.uniq), "duplicate committees"
  end

  def test_associations
    assert_nothing_raised { @first.bills }
    assert_instance_of Array, @first.bills, "Bills is not an array"
    assert @first.bills.size > 0, "No bills for this committee"
    assert_nothing_raised { @first.people }
    assert_instance_of Array, @first.people, "People is not an array"
  end

  def test_subcommittees
    assert_not_nil @standards, "Can't find house standards of official conduct committee"
    assert_equal @standards.subcommittees.size, 0, "House Standards of Official Conduct shouldn't have subcommittees"
    assert_not_nil @waysandmeans, "Can't find House Ways and means"
    assert @waysandmeans.subcommittees.size > 0, "Ways and means has no subcommittees?"
  end

  def test_committees_have_chair
    no_chair = []
    no_vice = []
    all = Committee.find_all
    all.each do |comm|
      peeps = comm.committee_people
      chair = peeps.select { |c| (!c.role.nil?) && c.role.match(/^chair/i) }
      no_chair.push(comm) if chair.empty?
      vice = peeps.select { |c| (!c.role.nil?) && c.role.match(/vice/i) }
      no_vice.push(comm) if vice.empty?
    end
    assert_not_equal no_chair.length, all.length, "No committees with chairmen"
    assert_not_equal no_vice.length, all.length, "No committees with vice chairmen"
  end

  def test_chair
    [@standards, @waysandmeans].each do |comm|
      assert_not_nil comm.chair, "No chair for #{comm.name}"
    end
    assert_equal @davis, @government_reform.chair, "Wrong chair for government reform as of Sept 12, 2006"
  end

  def test_vice_chair
    [@government_reform].each do |comm|
      assert_not_nil comm.vice_chair, "No vice chair for #{comm.name}"
    end
    assert_equal @shays, @government_reform.vice_chair, "Wrong vice chair for government reform as of Sept 12, 2006"
  end

  def test_ranking_member
    assert_not_nil @relations.ranking_member
    assert_equal @biden, @relations.ranking_member, "Wrong ranking member of Senate Foreign Relations as of 12 sept 06"
  end
  
  def test_random
    bs = nil
    assert_nothing_raised { bs = Committee.random(3) }
    assert_equal 3, bs.size, "Wrong number of committees"
    bs.each { |b| assert_kind_of Committee, b, "Funky SQL brokenness" }
    bs.each { |b| assert_equal b, Committee.find(b.id), "Equality is busted for random committees"}
  end

end

