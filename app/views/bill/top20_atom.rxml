xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@feed_title}"
  xml.link    "rel" => "self", "href" => url_for(:controller => 'bill/atom/most', :action => @most_type, :only_path => false)
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'bill/most', :action => @most_type)
  xml.updated @bills.first.bill_stats.send(@date_method).strftime("%Y-%m-%dT%H:%M:%SZ") if @bills.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/bill/most/#{@most_type}"

  @bills.each do |b|
    bill_basic_atom_entry(xml, b, @date_method)
  end
end