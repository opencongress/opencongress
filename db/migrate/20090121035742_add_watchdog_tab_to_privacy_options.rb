class AddWatchdogTabToPrivacyOptions < ActiveRecord::Migration
  def self.up
    add_column :privacy_options, :watchdog, :integer, :default => 2
    PrivacyOption.update_all('watchdog = 2')
  end

  def self.down
    remove_column :privacy_options, :watchdog
  end
end
