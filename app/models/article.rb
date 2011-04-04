class Article < ActiveRecord::Base
  acts_as_taggable

  has_many :comments, :as => :commentable
  belongs_to :user
  default_scope :order => 'created_at DESC'

  def self.per_page
    8
  end
 
  require 'RedCloth'
  
  def to_param
    title.blank? ? "#{id}" : "#{id}-#{title.gsub(/[^a-z0-9]+/i, '-')}"
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
    article.blank? ? "" : self.article.gsub(/<\/?[^>]*>/, "")
  end
  
  def excerpt_for_blog_page
    unless excerpt.blank?
      return excerpt
    else
      return "#{html_stripped[0..500]}..."
    end
  end
  
  def icon
    return case content_type
      when 'archive' then 'icons/page_white_compressed.png'
      when 'mockup' then 'icons/pictures.png'
      else                'icons/page_white_text.png'
      end
  end
  
  def formatted_date
    created_at.strftime "%B %e, %Y"
  end
  
  class << self
    def render_types
      ['markdown', 'html']
    end
  
    def recent_articles(limit = 10, offset = 0)
      Article.find(:all, :conditions => "published_flag = true", :offset => offset, :limit => limit)
    end
    
    def frontpage_gossip(number = 4)
      Article.find(:all, :limit => number, :conditions => 'frontpage = true')
    end
  
    def find_by_month_and_year(month, year)
      Article.find(:all, :conditions => [
              "date_part('month', articles.created_at) = ?
              AND date_part('year', articles.created_at) = ?
              AND published_flag = true", month, year],
                   :include => [:user, :comments])
    end
  
    def archive_months(limit, offset)
      Article.with_exclusive_scope { find(:all, :limit => limit, :offset => offset,
                   :select => "DISTINCT date_part('year', created_at) as year, date_part('month', created_at) as month, to_char(created_at, 'Month YYYY') as display_month",
                   :order => "year desc, month desc, display_month desc") }
    end
  
    def full_text_search(q, options = {})
      @s_count = Article.count(:all, :conditions => ["articles.published_flag = 't' AND fti_names @@ to_tsquery('english', ?)", q])
    
      # Note: This takes (current_page, per_page, total_entries)
      # We need to do this so we can put LIMIT and OFFSET inside the subquery.
      WillPaginate::Collection.create(options[:page], options[:per_page] || Settings.default_search_page_size, @s_count) do |pager|
        # perfom the find.
        # The subquery is here so we don't run ts_headline on all rows, which takes a long long time...
        # See http://www.postgresql.org/docs/8.4/static/textsearch-controls.html
        pager.replace Comment.find_by_sql(["
          SELECT *,
            ts_headline(article, ?) as headline
          FROM (
            SELECT articles.*, rank(fti_names, ?, 1) as tsearch_rank
            FROM articles
            WHERE articles.published_flag = 't' AND
            (fti_names @@ to_tsquery('english', ?))
            ORDER BY created_at DESC
            LIMIT ?
            OFFSET ?) AS comments", q, q, q, pager.per_page, pager.offset])
      end
    end
  end # class << self
end
