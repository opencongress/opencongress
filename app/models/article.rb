class Article < ActiveRecord::Base   
  acts_as_taggable_on :tags
  has_many :comments, :as => :commentable
  belongs_to :user

  require 'RedCloth'
  
  def to_param
    "#{id}-#{title.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  # hack - this is just used for linking in comment pagination
  def display_object_name
    "Articles"
  end
  
  def ident
    "Article #{id}"
  end

  def atom_id_as_entry
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/article/#{id}"
  end
  
  def atom_id_as_feed
    "tag:opencongress.org,#{created_at.strftime("%Y-%m-%d")}:/article_feed/#{id}"
  end
  
  def content_rendered
    return RedCloth.new(self.article).to_html
    
    if render_type == 'html'
      return self.article
    end
    return markdown(self.article)
  end
  
  def html_stripped
    self.article.gsub(/<\/?[^>]*>/, "")
  end
  
  def icon
    return case content_type
      when 'archive' then 'icons/page_white_compressed.png'
      when 'mockup' then 'icons/pictures.png'
      else                'icons/page_white_text.png'
      end
  end
  
  def self.render_types
    ['markdown', 'html']
  end
  
  def self.recent_articles(limit = 10, offset = 0)
    self.find(:all, :conditions => "published_flag = true", 
              :order => 'created_at DESC', :offset => offset, :limit => limit)
  end
    
  def self.frontpage_gossip(number = 4)
    Article.find :all, :limit => number, :order => "created_at desc", :conditions => 'frontpage = true'
  end
  
  def self.find_by_month_and_year(month, year)
    Article.find(:all, :conditions => [ "date_part('month', articles.created_at)=? AND 
                                         date_part('year', articles.created_at)=? AND published_flag=true", month, year],
                 :order => 'articles.created_at',
                 :include => [:user, :comments])
  end
  
  def Article.archive_months(limit, offset)
    Article.find(:all, :limit => limit, :offset => offset,
                 :select => "DISTINCT to_char(created_at, 'Month YYYY') as display_month,
                             date_part('year', created_at) as year, date_part('month', created_at) as month",
                 :order => "year desc, month desc")
  end
  
  def formatted_date
    created_at.strftime "%B %e, %Y"
  end
  
  def self.full_text_search(q, options = {}, find_options = {})
    articles = Article.paginate_by_sql(["SELECT articles.*, rank(fti_names, ?, 1) as tsearch_rank, headline(article,?) as headline
                                 FROM articles 
                                 WHERE articles.published_flag = 't' AND
                                        fti_names @@ to_tsquery('english', ?)                                       
                                 ORDER BY articles.created_at DESC", q, q, q],
                                :per_page => DEFAULT_SEARCH_PAGE_SIZE, :page => options[:page])
    articles
  end
end
