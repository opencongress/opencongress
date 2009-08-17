class CreateUserIpAddresses < ActiveRecord::Migration
  def self.up
    create_table :user_ip_addresses do |t|
      t.integer :user_id
      t.integer :addr

      t.timestamps
    end
  end

  def self.down
    drop_table :user_ip_addresses
  end
end
