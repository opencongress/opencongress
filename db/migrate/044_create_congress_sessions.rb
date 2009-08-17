class CreateCongressSessions < ActiveRecord::Migration
  def self.up
    create_table :congress_sessions do |t|
      t.column :chamber, :string
      t.column :date, :date
    end
  end

  def self.down
    drop_table :congress_sessions
  end
end
