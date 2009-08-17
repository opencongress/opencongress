class CommitteeFields < ActiveRecord::Migration
  def self.up
    add_column :committees, :code, :string
    add_column :committees_people, :session, :integer

    # all committee assignments thus far have been for the 109th congress
    execute "UPDATE committees_people SET session='109'"
  end

  def self.down
    drop_column :committees, :code
    drop_column :committees_people, :session
  end
end