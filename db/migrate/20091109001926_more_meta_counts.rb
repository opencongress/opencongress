class MoreMetaCounts < ActiveRecord::Migration
  def self.up
    add_column :bills, :news_article_count, :integer, :default => 0
    add_column :bills, :blog_article_count, :integer, :default => 0
    add_column :people, :news_article_count, :integer, :default => 0
    add_column :people, :blog_article_count, :integer, :default => 0
    
    [ 109, 110, 111 ].each do |c|
      bills = Bill.find_by_most_commentary('news', 100000, 10.years, c)
      bills.each do |b|
        b.news_article_count = b.article_count
        b.save
    
        puts "Bill (news): #{b.session}, #{b.typenumber}: #{b.news_article_count}"
      end
    
      bills = Bill.find_by_most_commentary('blog', 100000, 10.years, c)
      bills.each do |b|
        b.blog_article_count = b.article_count
        b.save
    
        puts "Bill (blog): #{b.session}, #{b.typenumber}: #{b.blog_article_count}"
      end
    end


    news_people = Person.find_by_sql("SELECT people.*, top_people.article_count AS article_count FROM people
                       INNER JOIN
                       (SELECT commentaries.commentariable_id, count(commentaries.commentariable_id) AS article_count
                        FROM commentaries 
                        WHERE commentaries.commentariable_type='Person' AND
                              commentaries.is_news='t' AND
                              commentaries.is_ok='t'
                        GROUP BY commentaries.commentariable_id
                        ORDER BY article_count DESC) top_people
                       ON people.id=top_people.commentariable_id
                       ORDER BY article_count DESC")                     
    news_people.each do |p|
      p.news_article_count = p.article_count
      p.save

      puts "Person (news): #{p.lastname}, #{p.news_article_count}"
    end
    
    blogs_people = Person.find_by_sql("SELECT people.*, top_people.article_count AS article_count FROM people
                       INNER JOIN
                       (SELECT commentaries.commentariable_id, count(commentaries.commentariable_id) AS article_count
                        FROM commentaries 
                        WHERE commentaries.commentariable_type='Person' AND
                              commentaries.is_news='f' AND
                              commentaries.is_ok='t'
                        GROUP BY commentaries.commentariable_id
                        ORDER BY article_count DESC) top_people
                       ON people.id=top_people.commentariable_id
                       ORDER BY article_count DESC")                     
    blogs_people.each do |p|
      p.blog_article_count = p.article_count
      p.save

      puts "Person (blog): #{p.lastname}, #{p.news_article_count}"
    end                      
  end

  def self.down
    remove_column :bills, :news_article_count
    remove_column :bills, :blog_article_count
    remove_column :people, :news_article_count
    remove_column :people, :blog_article_count
  end
end
