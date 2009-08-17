class WikiLinkScrapeBills < ActiveRecord::Migration
  def self.up
    WikiLink.scrape
  end

  def self.down
  end
end
