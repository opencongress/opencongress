class CreateBillCommentaries < ActiveRecord::Migration
  def self.up
    create_table :bill_commentaries do |t|
      t.column "bill_id", :integer
      t.column "commentary_type", :string
      t.column "title", :string
      t.column "url", :string
      t.column "excerpt", :text
      t.column "date", :datetime
      t.column "source", :string
      t.column "source_url", :string
      t.column "weight", :integer # not sure how this will be used yet
    end
  end

  def self.down
    drop_table :bill_commentaries
  end
end
