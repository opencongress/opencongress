module NotebookItemsHelper

  def url_for_internal(link)
    case link.notebookable.type.to_s
    when 'Bill'
      url_for :controller => 'bill', :action => "show", :id => link.notebookable.ident
    when 'Subject'
      url_for :controller => 'issues', :action => 'show', :id => link.notebookable.to_param      
    when 'Person'
      url_for :controller => 'people', :action => 'show', :id => link.notebookable.to_param
    when 'Commentary'
      link.url
    end    
  end
end
