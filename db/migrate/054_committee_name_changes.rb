class CommitteeNameChanges < ActiveRecord::Migration
  def self.up
    add_column :committees, :active, :boolean, :default => true
    
    return if Committee.find(:all) == []
    
    execute "UPDATE committees SET active='t'"
        
    @old_itnl_rel = Committee.find_by_name_and_subcommittee_name("House International Relations", nil)
    @new_for_aff = Committee.find_by_name_and_subcommittee_name("House Foreign Affairs", '')
    puts "OLD: #{@old_itnl_rel.name} / NEW: #{@new_for_aff.name}"
    
    @new_for_aff.subcommittee_name = nil
    @old_subs = Committee.find(:all, :conditions => [ "name = ? AND subcommittee_name IS NOT NULL", @old_itnl_rel.name])
    @old_subs.each do |c|
      new_c = Committee.new
      new_c.name = @new_for_aff.name
      new_c.subcommittee_name = c.subcommittee_name
      new_c.save
      
      c.active = false
      c.save
    end
    @new_for_aff.save
    
    @old_itnl_rel.active = false
    @old_itnl_rel.save
  
    @old_education = Committee.find_by_name_and_subcommittee_name("House Education and the Workforce",nil)
    @new_education = Committee.find_by_name_and_subcommittee_name("House Education and Labor", '')
    puts "OLD: #{@old_education.name} / NEW: #{@new_education.name}"

    @new_education.subcommittee_name = nil
    @old_subs = Committee.find(:all, :conditions => [ "name = ? AND subcommittee_name IS NOT NULL", @old_education.name])
    @old_subs.each do |c|
      new_c = Committee.new
      new_c.name = @new_education.name
      new_c.subcommittee_name = c.subcommittee_name
      new_c.save
      
      c.active = false
      c.save
    end
    @new_education.save
    
    @old_education.active = false
    @old_education.save
    
    @old_resources = Committee.find_by_name_and_subcommittee_name("House Resources", nil)
    @new_resources = Committee.find_by_name_and_subcommittee_name("House Natural Resources", '')
    puts "OLD: #{@old_resources.name} / NEW: #{@new_resources.name}"

    @new_resources.subcommittee_name = nil
    @old_subs = Committee.find(:all, :conditions => [ "name = ? AND subcommittee_name IS NOT NULL", @old_resources.name])
    @old_subs.each do |c|
      new_c = Committee.new
      new_c.name = @new_resources.name
      new_c.subcommittee_name = c.subcommittee_name
      new_c.save
      
      c.active = false
      c.save
    end
    @new_resources.save
    
    @old_resources.active = false
    @old_resources.save
    
    @old_science = Committee.find_by_name_and_subcommittee_name("House Science", nil)
    @new_science = Committee.find_by_name_and_subcommittee_name("House Science and Technology", '')
    puts "OLD: #{@old_science.name} / NEW: #{@new_science.name}"
    
    @new_science.subcommittee_name = nil
    @old_subs = Committee.find(:all, :conditions => [ "name = ? AND subcommittee_name IS NOT NULL", @old_science.name])
    @old_subs.each do |c|
      new_c = Committee.new
      new_c.name = @new_science.name
      new_c.subcommittee_name = c.subcommittee_name
      new_c.save
      
      c.active = false
      c.save
    end
    @new_science.save
    
    @old_science.active = false
    @old_science.save
    
    @old_reform = Committee.find_by_name_and_subcommittee_name("House Government Reform", nil)
    @new_reform = Committee.find_by_name_and_subcommittee_name("House Oversight and Government Reform", '')
    puts "OLD: #{@old_reform.name} / NEW: #{@new_reform.name}"
    
    @new_reform.subcommittee_name = nil
    @old_subs = Committee.find(:all, :conditions => [ "name = ? AND subcommittee_name IS NOT NULL", @old_reform.name])
    @old_subs.each do |c|
      new_c = Committee.new
      new_c.name = @old_reform.name
      new_c.subcommittee_name = c.subcommittee_name
      new_c.save
      
      c.active = false
      c.save
    end
    @new_reform.save

    @old_reform.active = false
    @old_reform.save    
  end

  def self.down
    remove_column :committees, :active
  end
end