class FixCommitteeSpelling < ActiveRecord::Migration
  #This migration fixes the spelling of committee in the schema.  The
  #model files already have it correctly spelled.  Also,
  #bills_committees is spelled correctly in the initial schema.

  def self.up
    rename_table :commitees, :committees
  end

  def self.down
    rename_table :committees, :commitees
  end
end
