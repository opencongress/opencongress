xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@page_title}"
  xml.link    "rel" => "self", "href" => url_for(:controller => 'bill', :action => 'readthebill.rss', :only_path => false)
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'bill', :action => 'readthebill')
  xml.updated @bills.first.originating_chamber_vote.datetime.strftime("%Y-%m-%dT%H:%M:%SZ") if @bills.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,#{Time.now.year}:/bill/readthebill/#{@sort}"

  @bills.each do |b|
    xml.entry do
      
      title = b.title_full_common
      if @sort == 'gpo'
        title += b.gpo_date.blank? ? "" : " - #{(Time.parse(b.consideration_date) - Time.parse(b.gpo_date)).to_i / 3600} hours"
      else
        title += " - #{bill.hours_to_first_attempt_to_pass} hours"
      end
      
      xml.title   title
      xml.link    "rel" => "alternate", "href" => bill_url(b)
      xml.id      b.atom_id_as_entry
      
      if @sort == 'gpo'        
        xml.updated Date.parse(b.consideration_date).strftime("%Y-%m-%dT%H:%M:%SZ")
      else
        xml.updated b.originating_chamber_vote.datetime.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
      
      xml.content "type" => "html" do
        if @sort == 'gpo'
          text = "#{b.title_official}<br /><br />"
          text += b.gpo_date.blank? ? "" : "Bill considered within #{(Time.parse(b.consideration_date) - Time.parse(b.gpo_date)).to_i / 3600} hours of text being available."
          xml.text! text
        else
          xml.text! "#{b.title_official}<br /><br />Attempted passage within #{b.hours_to_first_attempt_to_pass} hours of introduction."
        end
      end
    end
  end
end