class UpgradeOpenIdAuthenticationTables < ActiveRecord::Migration
  def self.up
    drop_table :open_id_authentication_settings
    drop_table :open_id_authentication_nonces

    create_table :open_id_authentication_nonces, :force => true do |t|
      t.column :timestamp, :integer, :null => false
      t.column :server_url, :string, :null => true
      t.column :salt, :string, :null => false
    end
  end

  def self.down
    drop_table :open_id_authentication_nonces

    create_table :open_id_authentication_nonces, :force => true do |t|
      t.integer :created
      t.string :nonce
    end

    create_table :open_id_authentication_settings, :force => true do |t|
      t.string :setting
      t.binary :value
    end
  end
end
