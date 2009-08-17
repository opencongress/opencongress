class ActionReferences < ActiveRecord::Migration
  def self.up
    create_table :action_references do |t|
      t.column :action_id, :integer 
      t.column :label, :string
      t.column :ref, :string
    end
  end

  def self.down
    drop_table :action_references
  end
end
