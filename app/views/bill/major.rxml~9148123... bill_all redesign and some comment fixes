xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : Hot Bills"
  xml.link    "rel" => "self", "href" => url_for(:controller => 'bill', :action => "hot.rss", :only_path => false)
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'bill', :action => 'hot')
  xml.updated @hot_bills.first.updated.strftime("%Y-%m-%dT%H:%M:%SZ") if @hot_bills.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2010:/bill/hot"

  @hot_bills.each do |b|
    bill_basic_atom_entry(xml, b, nil)
  end
end