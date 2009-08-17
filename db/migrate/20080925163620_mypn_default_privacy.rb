class MypnDefaultPrivacy < ActiveRecord::Migration
  def self.up
    change_column :privacy_options, :my_political_notebook, :integer, :default => 2
    execute "UPDATE privacy_options SET my_political_notebook=2"
  end

  def self.down
    change_column :privacy_options, :my_political_notebook, :integer, :default => 0
  end
end


