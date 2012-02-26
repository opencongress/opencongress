class DefenderColumns < ActiveRecord::Migration
  def self.up
    add_column :comments, :spam, :boolean
    add_column :comments, :defensio_sig, :string
    add_column :comments, :spaminess, :float
  end

  def self.down
    remove_column :comments, :spam
    remove_column :comments, :defensio_sig
    remove_column :comments, :spaminess
  end
end
