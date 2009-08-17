class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "login", :string
      t.column "password", :string
      t.column "admin", :boolean, :default => false
    end
   end

  def self.down
    drop_table :users
  end
end
