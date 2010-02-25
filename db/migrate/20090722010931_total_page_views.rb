class TotalPageViews < ActiveRecord::Migration
  def self.up
    add_column :bills, :page_views_count, :integer
    add_column :people, :page_views_count, :integer
    add_column :committees, :page_views_count, :integer
    add_column :subjects, :page_views_count, :integer
    
    [ 109, 110, 111 ].each do |c|
      bills = PageView.popular('Bill', 10.years, 100000, c)
      
      bills.each do |b|
        b.page_views_count = b.view_count
        b.save
      
        puts "Bill: #{b.session}, #{b.typenumber}: #{b.page_views_count}"
      end
    end
    
    PageView.popular('Person', 10.years, 100000).each do |b|
      b.page_views_count = b.view_count
      b.save
      puts "Person: #{b.lastname}: #{b.page_views_count}"
    end
    
    PageView.popular('Subject', 10.years, 100000).each do |b|
      b.page_views_count = b.view_count
      b.save
      puts "Issue: #{b.term}: #{b.page_views_count}"
    end

    PageView.popular('Committee', 10.years, 100000).each do |b|
      b.page_views_count = b.view_count
      b.save
      puts "Committee: #{b.name}: #{b.page_views_count}"
    end
  end

  def self.down
    remove_column :bills, :page_views_count
    remove_column :people, :page_views_count
    remove_column :committees, :page_views_count
    remove_column :subjects, :page_views_count
  end
end
