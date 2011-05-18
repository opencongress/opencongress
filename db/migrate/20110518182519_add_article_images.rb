class AddArticleImages < ActiveRecord::Migration
  def self.up
    create_table :article_images do |t|
      t.references :article
      t.string :image
    end
  end

  def self.down
    remove_table :article_images
  end
end
