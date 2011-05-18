class AddRootIdIndexToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, :root_id
  end

  def self.down
    change_table(:comments) do |t|
      t.remove_index :root_id
    end
  end
end
