class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books, :force => true do |t|
      t.column :category_id, :integer
      t.column :name, :string
      t.column :author, :string
      t.column :type, :string
      t.column :published_on, :date
    end
  end

  def self.down
    drop_table :books
  end
end
