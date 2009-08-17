
"Capital Markets, Insurance and Government Sponsored Enterprises"
class BioterrorismCorrectCommitteeName < ActiveRecord::Migration
  #I don't know if this warrants a migration, but once again I think
  #of migrations as a good way to keep track of things like this.
  def self.up
    c = Committee.find_by_subcommittee_name "Bioterrorism and Public Health Preparedness"
    unless c.nil?
      c.name = "Senate Health, Education, Labor, and Pensions";
      c.save
    end
    #note the double space
    cs = Committee.find_all_by_name "Senate Health, Education,  Labor, and Pensions"
    cs.each { |c| c.name = "Senate Health, Education, Labor, and Pensions"; c.save }
    cs = Committee.find :all, :conditions => ["subcommittee_name = ''"]
    cs.each { |c| c.subcommittee_name = nil; c.save }   
    c = Committee.find_by_subcommittee_name "Capital Markets, Insurance and Government Sponsored Enterprises"
    unless c.nil?
      c.subcommittee_name = "Capital Markets, Insurance, and Government Sponsored Enterprises"
      c.save
    end
    c = Committee.find_by_subcommittee_name "Middle East and Central Asia"
    unless c.nil?
      c.subcommittee_name = "The Middle East and Central Asia"
      c.save
    end
  end

  def self.down
    c = Committee.find_by_subcommittee_name "Bioterrorism and Public Health Preparedness"
    unless c.nil?
      c.name = ""
      c.save
    end
    cs = Committee.find_all_by_name "Senate Health, Education, Labor, and Pensions"
    cs.each { |c| c.name = "Senate Health, Education,  Labor, and Pensions"; c.save }
    cs = Committee.find :all, :conditions => ["subcommittee_name is null"]
    cs.each { |c| c.subcommittee_name = ''; c.save }
    c = Committee.find_by_subcommittee_name "Capital Markets, Insurance, and Government Sponsored Enterprises"
    unless c.nil?
      c.subcommittee_name = "Capital Markets, Insurance and Government Sponsored Enterprises"
      c.save
    end
    unless c.nil?
      c = Committee.find_by_subcommittee_name "The Middle East and Central Asia"
      c.subcommittee_name = "Middle East and Central Asia"
      c.save
    end
  end
end
