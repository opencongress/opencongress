class CreateComments < ActiveRecord::Migration
  def self.up
      add_column :comments, :title, :string
      add_column :comments, :updated_at, :datetime
      add_column :comments, :average_rating, :float, :default => 5.0
    execute "update comments set average_rating=5"
  end

  def self.down
      remove_column :comments, :title
      remove_column :comments, :updated_at
      remove_column :comments, :average_rating
  end
end
