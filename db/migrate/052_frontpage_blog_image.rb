class FrontpageBlogImage < ActiveRecord::Migration
  def self.up
    add_column :articles, :frontpage_image_url, :string
  end

  def self.down
    remove_column :articles, :frontpage_image_url
  end
end