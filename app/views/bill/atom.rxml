xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "#{@bill.title_full_common} Latest Actions"
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'bill', :action => 'atom', :id => @bill.ident )
  xml.link    "rel" => "alternate", "href" => bill_url(@bill)
  xml.id      @bill.atom_id_as_feed
  xml.updated @bill.actions.first.datetime.strftime("%Y-%m-%dT%H:%M:%SZ") if @bill.actions.any?
  xml.author  { xml.name "opencongress.org" }

  @bill.actions.each do |action|
    xml.entry do
      xml.title   action.action_type.capitalize
      xml.id      action.atom_id
      xml.link    "rel" => "alternate", "href" => bill_url(@bill)
      xml.updated action.datetime.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        @action = action
        xml.text! render(:partial => "bill/action.html")
        xml.text! render(:partial => "bill/rss_summary.html")
      end
    end
  end
end
