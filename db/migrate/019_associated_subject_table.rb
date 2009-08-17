class AssociatedSubjectTable < ActiveRecord::Migration
  def self.up
    create_table "subject_relations" do |t| #
      t.column "subject_id", :integer
      t.column "related_subject_id", :integer
      t.column "relation_count", :integer
    end
    add_index :subject_relations, [:subject_id, :related_subject_id, :relation_count]
  end

  def self.down
    drop_table :subject_relations
  end
end
