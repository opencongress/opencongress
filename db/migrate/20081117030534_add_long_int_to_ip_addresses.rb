class AddLongIntToIpAddresses < ActiveRecord::Migration
  def self.up
    #change_column(:user_ip_addresses, :addr, :integer, :limit => 20)
    change_column(:user_ip_addresses, :addr, :bigint)
  end

  def self.down
  end
end
