xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   @page_title
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'notebook_items', :action => 'feed')
  xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'notebook_items', :action => 'index')
  xml.id      @political_notebook.atom_id
  xml.updated @political_notebook.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
  xml.author  { xml.name "opencongress.org" }

  @items.each do |item|
    xml.entry do
      xml.title   item.title
      xml.id      item.atom_id
      case item.type.to_s
      when 'NotebookFile'
        if @group
          xml.link    "rel" => "alternate", "href" => group_path(@group)
        else
          xml.link    "rel" => "alternate", "href" => political_notebook_notebook_file_path(:login =>@user.login,:id => item.id)
        end
      when 'NotebookNote'
        if @group
          xml.link    "rel" => "alternate", "href" => group_path(@group)
        else
          xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'notebook_items', :action => 'index')
        end
      when 'NotebookLink'
        if item.is_internal?
          xml.link    "rel" => "alternate", "href" => url_for_internal(item)
        else
          xml.link    "rel" => "alternate", "href" => item.url
        end
      when 'NotebookVideo'
        xml.link    "rel" => "alternate", "href" => item.url
      else
        xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'notebook_items', :action => 'index')
      end
  
      xml.updated item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.content "type" => "html" do
        @item = item
        xml.text! item.description unless item.description.blank?
      end
    end
  end
end
