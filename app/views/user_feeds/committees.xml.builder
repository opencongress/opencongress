xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "Open Congress : #{@title}" 
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'profile', :action => params[:action], :login => params[:login] )
  xml.updated @items.first.reported_at.strftime("%Y-%m-%dT%H:%M:%SZ") if @items.any?
  xml.author  { xml.name "opencongress.org" }
  @items[0..19].each do |i|
      case i.class.name
      when 'CommitteeReport'
        xml.entry do
          xml.link "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'committee', :action => 'show', :id => i.committee.to_param)
          xml.id   i.atom_id
          xml.updated i.reported_at.strftime("%Y-%m-%dT%H:%M:%SZ")
          xml.title "New Report from #{i.committee.name}: #{i.name}"
          xml.content "type" => "html" do
            xml.text! "#{h(i.title.titleize)}"
          end
        end
      when 'BillAction'
            bill_action_atom_entry(xml, i)
      end
  end
end
