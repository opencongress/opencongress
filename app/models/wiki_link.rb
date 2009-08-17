class WikiLink < ActiveRecord::Base
  belongs_to :wikiable, :polymorphic => true
  before_validation :clean_up


  def clean_up
    self.wikiable_id = Object.const_get(self.wikiable_type).find_by_ident(self.wikiable_id).id if self.wikiable_type == "Bill" && self.wikiable_id =~ /([0-9]{3})-/
    self.wikiable_id = Object.const_get(self.wikiable_type).find(self.wikiable_id).id if ( self.wikiable_type == "Person" || self.wikiable_type == "Committee" || self.wikiable_type == "Subject" )
  end
  
  
  def self.scrape
    require 'open-uri'
    require 'hpricot'
    
    url = 'http://www.opencongress.org/w/index.php?title=Special:Ask&offset=0&limit=500&q=[[Category:Tagged+legislation]]&p=format%3Dbroadtable&po=%3FBillnumber%3D%0A%3FCongressnumber%3D%0A'
    
    doc = Hpricot(open(url))
    table = (doc/"table[@class='smwtable']")
    (table/"tr").each do |t|
      wiki_bill_td = (t/"td:nth(0)")
      bill_id_td = (t/"td:nth(1)")
      congress_td = (t/"td:nth(2)")
      unless wiki_bill_td.inner_html.blank?
        wiki_name = ""
        bill_ids = []
        congress = ""
        oc_link = ""
        wikiable_type = "Bill"
        l = (wiki_bill_td/"a").first['href']
        if l =~ /\/wiki\/(.*)/
          wiki_name = $1
        end
        
        unless wiki_name.blank?
          bill_ids_a = (bill_id_td/"a")
          bill_ids = []
          bill_ids_a.each do |bid|
            bill_ids << bid.inner_html.downcase unless bid.inner_html.blank?
          end
          congress = (congress_td/"a").first.inner_html unless (congress_td/"a").empty?
          unless congress.blank?
            bill_ids.each do |rock|
              this_ident = "#{congress}-#{rock}"
              bill = Bill.find_by_ident(this_ident)
              if bill
                w = WikiLink.find_or_initialize_by_wikiable_type_and_wikiable_id('Bill', bill.id)
                w.oc_link = "http://www.opencongress.org/bill/#{bill.ident}/show"
                w.name = wiki_name
                w.save!
                puts "#{this_ident} - #{wiki_name}"
              end
            end
          end
        end
      end
    end
        
      return ""
  end
  

end
