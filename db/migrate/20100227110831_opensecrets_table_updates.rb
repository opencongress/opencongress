class OpensecretsTableUpdates < ActiveRecord::Migration
  def self.up
    add_column :crp_contrib_pac_to_candidate, :fec_cand_id, :string
    
  end

  def self.down
    remove_column :crp_contrib_pac_to_candidate, :fec_cand_id
  end
end
