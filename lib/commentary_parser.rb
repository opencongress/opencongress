#require File.dirname(__FILE__) + '/../app/models/page_view.rb'
#require File.dirname(__FILE__) + '/../app/models/person.rb'
#require File.dirname(__FILE__) + '/../app/models/bill.rb'

require 'uri'
require 'rexml/document'
require 'ostruct'
require 'hpricot'
require 'open-uri'
require 'iconv'
require 'digest/md5'
require 'o_c_logger'

module CommentaryParser
  USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'
  STOP_REFERRERS = [ "google\.com" ]
  @@proxies = []
  @@proxy = nil
  @@use_proxy = (ENV['USE_PROXY'] == 'true')
  
  def CommentaryParser.save_items(items, lookup_object, type, scraped_from)
    n = items ? items.size : 0
    new_items = false
    #OCLogger.log "Found #{n} items."
    
    #OCLogger.log "THIS IS THE OBJECT: #{lookup_object.inspect}"

    if n > 0
      items.each do |i|
        unless is_dupe(i, lookup_object)
          new_items = true if save_item(i, lookup_object, type, scraped_from)            
        end
      end
      
      lookup_object.expire_commentary_fragments(type) if new_items
    end
  end

  def CommentaryParser.is_dupe(i, lookup_object)
    # check to see if this item is already in the DB
    c = Commentary.find_by_sql(["SELECT * FROM (SELECT commentaries.url, commentaries.commentariable_type, commentaries.commentariable_id FROM commentaries UNION ALL SELECT bad_commentaries.url, bad_commentaries.commentariable_type, bad_commentaries.commentariable_id FROM bad_commentaries) AS c WHERE c.url=? AND c.commentariable_type=? AND c.commentariable_id=? LIMIT 1", i.url, lookup_object.class.to_s, lookup_object.id])
    unless c.empty?
      OCLogger.log "Item (URL) already in database"
      return true
    else
      return false
    end
  end
    
  def CommentaryParser.save_item(i, lookup_object, type, scraped_from)
    saved = false
    commentary_type = i.commentary_type.nil? ? type : i.commentary_type
    
    Commentary.transaction {
      c = Commentary.new
    
      c.commentariable = lookup_object
      c.is_news = (commentary_type == 'news') ? true : false
      #c.is_ok = false
      c.url = i.url
      if i.title
        c.title = i.title.gsub(/<\/?[^>]*>/, "")
      end
      c.scraped_from = scraped_from
      c.source_url = i.source_url unless (scraped_from == 'google news')
    
      if scraped_from == 'technorati'
        # noticed this on 1/16/08: getting some nil excerpts from technorati
        # for now, skip this article
        if i.excerpt.nil?
          OCLogger.log "Got nil excerpt from technorati, not saving."
          return false
        end
        
        c.excerpt = i.excerpt[0..255]
        c.date = DateTime.strptime(i.date, "%Y-%m-%d %H:%M:%S %Z")
        c.weight = i.weight
        c.source = i.source
      else
        # strip any HTML from the excerpt
        c.excerpt = i.excerpt.gsub(/<\/?[^>]*>/, "")[0..255]
        
        if m_matches = /(\d+) minute(s*) ago/.match(i.date)
          c.date = (Time.now - (m_matches[1].to_i * 60)).to_date
        elsif h_matches = /(\d+) hour(s*) ago/.match(i.date)
          c.date = (Time.now - (h_matches[1].to_i * 60 * 60)).to_date
        elsif d_matches = /(\d+) day(s*) ago/.match(i.date)
          c.date = (Time.now - (d_matches[1].to_i * 60 * 60 * 24)).to_date
        else
          begin
            if scraped_from == 'google news'
              i.date.gsub!(/&lrm;/, "")
              
              c.date = Date.strptime(i.date, "%b %d, %Y")
            elsif scraped_from == 'daylife'
              c.date = Date.strptime(i.date, "%Y-%m-%d %H:%M:%S")
            elsif scraped_from == 'bing'
              c.date = DateTime.parse(i.date)
            else
              c.date = Date.strptime(i.date, "%b %d, %Y")
            end
          rescue ArgumentError
            OCLogger.log "Warning: Couldn't parse date from Google. #{$!}"
            c.date = Date.today
          end
        end
      
        if scraped_from == 'google news'
          # strip the &nbsp;-&nbsp; on GOOGLE NEWS
          c.source = i.source.gsub(/&nbsp;-$/, "")
          #OCLogger.log "NEWS SOURCE: #{c.source} / SOURCEURL: #{c.source_url}"
        else
          last_dash = i.source.rindex(/ - /)
          c.source = (last_dash ? i.source[0..last_dash] : i.source)
        end
      end

      unless ((lookup_object.kind_of? Bill) && 
              (c.date < (Time.at(lookup_object.introduced) - 2.days).to_date))
        begin
          # Bing is excluded from strict checks because their search results don't always
          # include the search term
          if c.commentariable_type == 'Bill' && c.commentariable.bill_type == 's' && 
             ((status = c.senate_bill_strict_validity) != 'OK') && scraped_from != 'bing'
            c.status = status
            OCLogger.log "Article failed strict check because it is a senate bill. #{c.status}"
          else
            if c.article_valid?
              c.status = 'OK'
              c.is_ok = true;
              #OCLogger.log "Article verified.  Matched: #{c.contains_term}"
            else
              c.status = 'NO MATCH'
              #OCLogger.log "Article failed verification."
            end
          end
          
          if (c.status == 'OK' || c.status == 'PENDING') 
            unless c.save && lookup_object.save
              OCLogger.log "Couldn't save item: " + c.errors
            else
              saved = true
              OCLogger.log "Saved #{commentary_type} item.  URL: #{c.url}"
            
              c.commentariable.increment!(c.is_news ? :news_article_count : :blog_article_count) if c.is_ok?            
              #OCLogger.log "ITEM: #{c.inspect}"
            end
          else
            bc = BadCommentary.new(:url => c.url, :commentariable_id => c.commentariable_id, :commentariable_type => c.commentariable_type, :date => c.date)
            unless bc.save
              OCLogger.log "Couldn't save bad commentary item: " + c.errors + "\n" + bc.inspect
            else
              saved = true
              OCLogger.log "Saved bad commentary: #{commentary_type} item.  URL: #{c.url}"
            end
            
          end
        rescue 
          OCLogger.log "Exception trying to save item: #{$!}\n#{c.inspect}"
        end
      else
        #OCLogger.log "Article written more than two days before bill introduced! Skipping."
      end
    }
    
    saved
  end

  def CommentaryParser.get_technorati_cosmos_items_for_query(query)
    OCLogger.log "Looking for technorati cosmos items matching '#{query}'"

    host = "api.technorati.com"
    path = "/cosmos?key=#{ApiKeys.technorati_api_key}&limit=50&language=en&query=#{query}"
    
    get_technorati_items_for_host_and_path(host, path)
  end
  
  def CommentaryParser.get_technorati_search_items_for_query(query)
    OCLogger.log "Looking for technorati search items matching '#{query}'"

    host = "api.technorati.com"
    path = "/search?key=#{ApiKeys.technorati_api_key}&limit=50&language=en&query=#{query}"
    
    get_technorati_items_for_host_and_path(host, path)
  end
  
  def CommentaryParser.get_bing_news_items_for_query(query)
    OCLogger.log "Looking for Bing news items matching '#{query}'"

    host = "api.bing.net"
    path = "/xml.aspx?AppId=#{ApiKeys.bing}&Version=2.2&Market=en-US&Query=#{query}&Sources=news&News.Count=15"
    
    get_bing_items_for_host_and_path(host, path)
  end
  
  def CommentaryParser.get_daylife_items_for_query(query)
    OCLogger.log "Looking for daylife search items matching '#{URI.unescape(query)}'"

    signature = Digest::MD5.hexdigest("#{ApiKeys.daylife_access_key}#{ApiKeys.daylife_secret}#{URI.unescape(query)}")

    host = "freeapi.daylife.com"
    path = "/xmlrest/publicapi/4.3/search_getRelatedArticles?query=#{query}&accesskey=#{ApiKeys.daylife_access_key}&signature=#{signature}"
    
    get_daylife_items_for_host_and_path(host, path)
  end
  
  def CommentaryParser.get_technorati_items_for_host_and_path(host, path)
    #OCLogger.log "URL: #{url}"
    res = nil
    begin
      body = get_body_for_host_and_path(host, path)

      rex_doc = REXML::Document.new body
  
      items = []
      rex_doc.elements.each("tapi/document/item") do |i|
        temp_item = OpenStruct.new
    
        temp_item.url = i.text("permalink")
        temp_item.title = i.text("title")
        temp_item.excerpt = i.text("excerpt")
        temp_item.date = i.text("created")
        temp_item.source = i.text("weblog/name")
        temp_item.source_url = i.text("weblog/url")
        temp_item.weight = i.text("weblog/inboundlinks")
    
        items << temp_item
      end
    rescue 
      OCLogger.log "Error scraping Technorati! #{$!.backtrace}"
      return []
    end
  
    items
  end
  
  def CommentaryParser.get_bing_items_for_host_and_path(host, path)
    #OCLogger.log "URL: #{url}"
    res = nil
    begin
      body = get_body_for_host_and_path(host, path)

      rex_doc = REXML::Document.new body
  
      items = []
      rex_doc.elements.each("SearchResponse/news:News/news:Results/news:NewsResult") do |i|
        temp_item = OpenStruct.new
    
        temp_item.url = i.text("news:Url")
        temp_item.title = i.text("news:Title")
        temp_item.excerpt = i.text("news:Snippet")
        temp_item.date = i.text("news:Date")
        temp_item.source = i.text("news:Source")
    
        items << temp_item
      end
    rescue 
      OCLogger.log "Error scraping Bing! #{$!.backtrace}"
      return []
    end
  
    items
  end
  
  def CommentaryParser.get_daylife_items_for_host_and_path(host, path)
    #OCLogger.log "URL: #{url}"
    res = nil
    begin
      body = get_body_for_host_and_path(host, path)
      #OCLogger.log "GOT BODY: #{body}"
      rex_doc = REXML::Document.new body
  
      items = []
      rex_doc.elements.each("response/payload/article") do |i|
        unless i.text("url").blank?
          temp_item = OpenStruct.new
    
          temp_item.url = i.text("url")
          temp_item.title = i.text("headline")
          temp_item.excerpt = i.text("excerpt")
          temp_item.date = i.text("timestamp")
          temp_item.source = i.text("source/name")
          temp_item.source_url = i.text("source/url")
          
          source_type = i.text("source/type")
          temp_item.commentary_type = (source_type == "2") ? 'blog' : 'news'
          
          #temp_item.weight = i.text("weblog/inboundlinks")
    
          items << temp_item
        
          #OCLogger.log "GOT TEMP ITEM: #{temp_item.inspect}"
        end
      end
    rescue 
      OCLogger.log "Error scraping Daylife! #{$!.backtrace}"
      return []
    end
  
    items
  end

  def CommentaryParser.get_google_items_for_query(query)
    OCLogger.log "Looking for google news items matching '#{query}'"

    items = []
    host = "news.google.com"
    path = "/news?hl=en&ned=us&q=#{query}&btnG=Search+News&num=50"

    begin
      body = get_body_for_host_and_path(host, path)
      doc = Hpricot(body)
    
      details = doc/"div.story"
      
      place = 0
      details.each do |d|
        #OCLogger.log d.inspect
        
        place += 1
        t = d.at("h2.title a.article")

        os = OpenStruct.new
      
        os.title = (t.inner_html) if t #.unpack("C*").pack("U*") if t
        os.url = t.attributes["href"] if t
        os.date = d.at("span.date").inner_html
        os.source = d.at("span.source").inner_html
        os.excerpt = d.at("div.snippet").inner_html #.unpack("C*").pack("U*")
        
        items << os
      end
    rescue
      OCLogger.log "Error scraping Google News Search! #{$!} \n\n#{$!.backtrace}"
    end
  
    items
  end

  
  def CommentaryParser.get_google_blog_items_for_query(query)
    OCLogger.log "Looking for google blog items matching '#{query}'"
    items = []
    
    host = "www.google.com"
    path = "/search?hl=en&ie=UTF-8&q=#{query}&tbm=blg"

    begin
      body = get_body_for_host_and_path(host, path)      
      
      doc = Hpricot(body)
    
      posts = doc/"li.g"

      place = 0
      posts.each do |d|
        #OCLogger.log "\n\n\n\n\n\n\nGOT SNIP: #{d}\n\n\n\n\n\n\n\n\n\n"
        title_a = d.at("h3.r a") 
        
        unless (title_a.inner_html =~ /Related blogs about/ or
                title_a.inner_html =~ /Blog homepages for/)
          os = OpenStruct.new
              
          os.title = (title_a.inner_html)
          os.url = title_a.attributes["href"]
          
          
          date_source = d.at(".f")
          if date_source
            if date_source.inner_html =~ / by /
              os.date, os.source = date_source.inner_html.split(/ by /)
            else
              os.date = date_source.inner_html
            end
          end
            
          os.source = d.at("cite a").inner_html if os.source.nil?
          os.source_url = d.at("cite a").attributes["title"]
          
          excerpt_div = d.at("div.s")
          excerpt_div.search("span.f").remove if excerpt_div.search("span.f").any?
          excerpt_div.search("a").remove if excerpt_div.search("a").any?
          excerpt_div.search("cite").remove if excerpt_div.search("cite").any?
          
          os.excerpt = excerpt_div.inner_html
        
          items << os
        end
      end
    rescue
      OCLogger.log "Error scraping Google Blog Search! #{$!} \n\n#{$!.backtrace}"
    end
  
    items
  end

  def CommentaryParser.get_body_for_host_and_path(host, path)
    $DEBUG = false
    tries = 0
    got_doc = false
    
    begin
      if @@use_proxy
        if @@proxies.empty?
          OCLogger.log "Getting proxy list..."
          
          m = Mechanize.new
          m.user_agent_alias = "Windows IE 7"

          m.get("http://hidemyass.com/proxy-list/search-235102")

          p = m.page.parser
          p.css('#listtable tr').each_with_index do |row, i|
            unless i == 0
              ip = row.css('td')[1].css('span').first

              unless ip.attributes['title'] == 'Planet Lab proxy'
                @@proxies << [ip.text,row.css('td')[2].text.strip]
              end
            end
          end
        end
      
        begin
          if @@proxy.nil?
            the_proxy = @@proxies[rand(@@proxies.size)]
          else
            the_proxy = @@proxy
          end
        
          OCLogger.log "Trying proxy: #{the_proxy[0]}:#{the_proxy[1]}..."
        
          response = nil;
          Net::HTTP::Proxy(the_proxy[0], the_proxy[1]).start(host) do |http|
            request = Net::HTTP::Get.new(path, {"User-Agent" => USERAGENT})
            begin
              response = http.request(request)
            rescue Timeout::Error
              response = nil
              tries += 1
            end
          end
        end while (!response.kind_of? Net::HTTPSuccess and tries < 3)
        @@proxy = the_proxy if @@proxy.nil?
      else
        begin
          response = nil;
          http = Net::HTTP.new(host)
          http.start do |http|
            request = Net::HTTP::Get.new(path, {"User-Agent" => USERAGENT})
          
            begin
              response = http.request(request)
            rescue Timeout::Error
              response = nil
            end

            if response and response.kind_of?(Net::HTTPSuccess)
              got_doc = true
            else
              if (response.header['location'] != nil)
                newurl = URI.parse(response.header['location'])
                if(newurl.relative?)
                  path = response.header['location']
                else
                  host = newurl.host
                  path = newurl.path
                end
              end 
            end
            tries += 1
          end
        end while (!got_doc and (tries < 3))
      end
      
      return response.nil? ? "<html></html>" : response.body
    rescue
      OCLogger.log "Error or timeout retrieving url: #{host}#{path}. #{$!}.  Skipping."
      return "<html></html>"
    end
  end
  
  def CommentaryParser.do_queries(query, lookup_object)
    items = get_google_blog_items_for_query(query)
    save_items(items, lookup_object, 'blog', 'google blog')
  
    items = get_technorati_search_items_for_query(query)
    save_items(items, lookup_object, 'blog', 'technorati')
  
    items = get_bing_news_items_for_query(query)
    save_items(items, lookup_object, 'news', 'bing')
    
    items = get_google_items_for_query(query)
    save_items(items, lookup_object, 'news', 'google news')
    
    items = get_daylife_items_for_query(query)
    save_items(items, lookup_object, 'news', 'daylife')
  end
  
  def CommentaryParser.do_referrer_queries(query, lookup_object)
    items = get_google_blog_items_for_query(query)
    save_items(items, lookup_object, 'blog', 'google blog (referrer lookup)')
  
    items = get_technorati_cosmos_items_for_query(query)
    save_items(items, lookup_object, 'blog', 'technorati cosmos (referrer lookup)')
  end

  def CommentaryParser.bill_query(bill)
    URI.escape(bill.typenumber)
  end

  def CommentaryParser.person_query(person)
    URI.escape("#{person.title} \"#{person.popular_name}\"")
  end
  
  def CommentaryParser.bill_referrer_query(bill)
    "http://www.opencongress.org/bill/#{bill.ident}/show"
  end

  def CommentaryParser.find_referring_posts_for_bill?(bill)
    # returns true unless we have all the referrings posts already
    bill.bill_referrers.each do |r|
      #OCLogger.log "#{r}"
      if BillReferrer.no_follow?(r.url)
        #OCLogger.log "From google, skipping."
      else
        unless Commentary.find(:first, :conditions => ["url=?", r.url])
          #OCLogger.log "Didn't find, will search"
          return true
        end
      end
    end
    
    # if we got here, we have all the referring articles
    return false
  end
  
  def CommentaryParser.all_bills_for_current_session
    bills = Bill.find(:all, :conditions => [ "session = ?", Settings.default_congress ], :order => 'lastaction DESC')
    i = 0 
    bills.each do |b|
      i += 1
      OCLogger.log "Finding commentary for bill: #{b.typenumber} #{i}/#{bills.size} (all bills)"

      do_queries(bill_query(b), b)
    end
    
    Bill.expire_meta_commentary_fragments
  end


  def CommentaryParser.most_viewed_and_recent_activity_bills
    most_viewed_bills = ObjectAggregate.popular('Bill')
    recent_activity = Bill.find(:all, 
                                :conditions => ["bills.id IN (SELECT bill_id FROM actions 
                                                        WHERE actions.datetime > ? 
                                                        GROUP BY bill_id)", 2.days.ago],
                                :order => "bills.lastaction DESC")                         
  
    bills = (most_viewed_bills | recent_activity) 
    
    i = 0 
    bills.each do |b|
      i += 1
      OCLogger.log "Finding commentary for bill: #{b.typenumber} #{i}/#{bills.size} (popular/recent activity)"

      do_queries(bill_query(b), b)
    end

    Bill.expire_meta_commentary_fragments    
  end


  def CommentaryParser.all_people_for_current_session
    people = Person.representatives.concat(Person.senators)
    i = 0 
    people.each do |p|
      i += 1
      OCLogger.log "Finding commentary for person: #{p.popular_name} #{i}/#{people.size} (all_people)"
  
      do_queries(person_query(p), p)
    end
    
    Person.expire_meta_commentary_fragments
  end
  
  def CommentaryParser.recent_referrers                                
    referred_bills = Bill.where("bills.id IN (SELECT DISTINCT bill_id FROM bill_referrers)")
                                            
    i = 0
    referred_bills.each do |rb|
      i += 1
      OCLogger.log "Looking for referrers for #{rb.title_full_common}"
      
      if find_referring_posts_for_bill?(rb)
        OCLogger.log "Looking for referring posts for bill: #{i}/#{referred_bills.size} (recent_referrers)"
        
        do_referrer_queries(bill_referrer_query(rb), rb)
      else
        OCLogger.log "Skipping bill (have all referrers or matched no-follows): #{i}/#{referred_bills.size} (recent_referrers)"
      end
    end
    
    Bill.expire_meta_commentary_fragments
    
    # delete referrers older than two days
    BillReferrer.purge
  end
end



