#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'o_c_logger'

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  OCLogger.log "Running from #{$0}"
end



def metavid_item_to_video(item, person = nil)
  OCLogger.log "Got a metavid video: #{item.text('title')}"
  #OCLogger.log "EMBED: #{item.elements['media:roe_embed'].attributes['url']}"
  
  embed = item.elements['media:roe_embed'].attributes['url']
  vid_url = item.text('link')
  
  Video.transaction {
    v = Video.find_or_initialize_by_url(vid_url.strip)
    v.title = item.text('title')
    v.source = 'metavid'
  
    v.embed = %Q{<video roe="#{embed}"></video>}
    
    # pull the date from the title
    md = /\d+-\d+-\d+/.match(v.title)  
    v.video_date = md ? Date.strptime(md[0].chomp, "%m-%d-%y") : nil
  
    # calculate the length from the title
    md = /(\d+:\d+:\d+) to (\d+:\d+:\d+)/.match(v.title)    
    if md[1] and md[2]
      #OCLogger.log "LENGTH: #{(Time.parse(md[2]) - Time.parse(md[1])).to_i} seconds"
      v.length = (Time.parse(md[2]) - Time.parse(md[1])).to_i
    end
  
    if person.nil?
      desc = Hpricot(item.elements['description'].to_a[1].to_s)
      desc_links = desc.search("p/a")
      
      if desc_links.size == 1
        if desc_links[0].index(":")
          bill_name =  desc_links[0].attributes['title'].split(": ")[0]
        else
          person_name = desc_links[0].attributes['title']
        end
      elsif desc_links.size == 2
        person_name = desc_links[0].attributes['title']
        bill_name =  desc_links[1].attributes['title'].split(": ")[0]
      end
      
      unless bill_name.blank?
        bill_long_type, bill_number = bill_name.split(" ")
        bill = Bill.find_by_session_and_number_and_bill_type(Bill.session_from_date(v.video_date), bill_number, Bill.long_type_to_short(bill_long_type))
        v.bill = bill if bill
      end
    
      unless person_name.blank?
        name_a = []
        person_name.split.each do |n|
          name_a << n.split("\.")
        end
        name_a.flatten!
      
        # use first and last in array to 
        p = Person.find(:first, :include => :roles, 
                             :conditions => ["(UPPER(people.firstname)=? OR UPPER(people.middlename)=? OR UPPER(people.nickname)=?) AND 
                                              UPPER(people.lastname)=? AND roles.startdate <= ? AND roles.enddate > ?",
                                             name_a.first.upcase, name_a.first.upcase, name_a.first.upcase,
                                             name_a.last.upcase, v.video_date, v.video_date])
        v.person = p if p
      end
    else
      v.person = person
    end
  
    v.save
  }
end

def youtube_item_to_video(item, person = nil)
  OCLogger.log "Got a youtube video: #{item.text('title')}"
  #OCLogger.log "inspect: #{item}"
  vid_url = item.text('link')
  yt_id = nil
  
  Video.transaction {
    v = Video.find_or_initialize_by_url(vid_url.strip)
    v.title = item.text('title')
    v.source = 'youtube'
    
    # get youtube ID from the
    v.url.split(/\?/).last.split(/\&/).each do |kv|
      key, val = kv.split(/\=/)
      if key == 'v'
        yt_id = val
      end
    end 
    
    v.embed = %Q{<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/#{yt_id}&hl=en&fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/#{yt_id}&hl=en&fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
    v.video_date = Date.parse(item.text('pubDate'))
  
    #OCLogger.log "DESC: #{item.text('description')}"
    item_desc = Hpricot(item.text('description'))
    
    desc = item_desc.at("div[@style='font-size: 12px; margin: 3px 0px;'] span").inner_html  
    v.description = desc
    
    vid_time = item_desc.at("span[@style='color: #000000; font-size: 11px; font-weight: bold;']").inner_html
    #OCLogger.log "vid_time: #{vid_time}"
    vid_length = (vid_time.length == 8) ? vid_time : "00:#{vid_time}"  
    vid_length = (Time.parse(vid_length) - Time.parse("00:00:00")).to_i
    v.length = vid_length

    v.person = person
  
    v.save
  }
end

people = Person.all_sitting

people.each_with_index do |p, i|
  OCLogger.log "Checking videos for #{p.name} (#{i+1}/#{people.size})"
  
  # check metavid
  unless p.metavid_id.blank?  
    url  = "http://metavid.org/w/index.php?title=Special:MvExportSearch&order=recent&f%5B0%5D%5Ba%5D=and&f%5B0%5D%5Bt%5D=speech_by&f%5B0%5D%5Bv%5D=#{p.metavid_id.gsub(/_/, '+')}"
    
    OCLogger.log "Metavid URL: #{url}"
    begin
      doc = REXML::Document.new(open(url))
    
      doc.elements.each("rss/channel/item") do |item|
        metavid_item_to_video(item, p)
      end
      
    rescue Exception => e
      OCLogger.log "Error parsing metavid #{e}"
    end
  end
  
  # check youtube
  unless p.youtube_id.blank?  
    url  = "http://gdata.youtube.com/feeds/base/users/#{p.youtube_id}/uploads?alt=rss&v=2&client=ytapi-youtube-profile"

    OCLogger.log "youtube URL: #{url}"

    begin
      doc = REXML::Document.new(open(url))
    
      doc.elements.each("rss/channel/item") do |item|
        youtube_item_to_video(item, p)
      end
      
    rescue Exception => e
      OCLogger.log "Error parsing youtube #{e}"
    end
  end
end

# now check for bills (metavid only, for now)
url = "http://metavid.org/wiki/Special:MvExportAsk?q=[[Bill%3A%3A%3Cq%3E[[Category%3ABill]]%3C%2Fq%3E]]&po=&sc=0&eq=yes&limit=1000&offset=0"
begin
  OCLogger.log "Checking metavid bills page..."
  doc = REXML::Document.new(open(url))
  
  doc.elements.each("rss/channel/item") do |item|
    metavid_item_to_video(item)
  end
    
rescue Exception => e
  OCLogger.log "Error parsing metavid #{e}"
  raise e
end

