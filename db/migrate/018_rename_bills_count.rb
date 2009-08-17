class RenameBillsCount < ActiveRecord::Migration
  def self.up
    # bills count is a magic method. Instead of renaming the column
    # we had to pretend it never existed. We kept this as a null migration
    # to avoid leaving a gap.
  end

  def self.down
  end
end
