class AddIpToApiHits < ActiveRecord::Migration
  def self.up
    add_column :api_hits, :ip, :string, :limit => 50
  end

  def self.down
    remove_column :api_hits, :ip
  end
end
