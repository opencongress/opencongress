xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@xml_title}"
  xml.link    "rel" => "self", "href" => url_for(@self_href)
  xml.link    "rel" => "alternate", "href" => url_for(@alt_href)
  xml.updated @people.first.stats.send(@date_method).strftime("%Y-%m-%dT%H:%M:%SZ") if @people.any?
  xml.author  { xml.name "opencongress.org" }
  xml.id      "tag:opencongress.org,2007:/people#{@atom_path}"

  @people.each do |p|
    person_basic_atom_entry(xml, p, @date_method)
  end
end