xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "OpenCongress Blog"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'gossip', :action => 'index' )
  #xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'bill', :action => :index )
  #xml.id      url_for(:only_path => false, :controller => 'bill', :id => @bill.ident, :action => 'show')
  xml.updated @gossip.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ") if @gossip.any?
  xml.author  { xml.name "opencongress.org" }

  @gossip.each do |g|
    xml.entry do
      xml.title   g.title
      xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'gossip', :action => 'index')
      #xml.id      bill_url(@bill)
      xml.updated g.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      #xml.author  { xml.name action.author.name }
      #xml.summary action.to_s
      xml.content "type" => "html" do
        xml.text! g.tip
      end
    end
  end
end
