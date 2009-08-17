module NotebookLinksHelper
  def default_title_from_notebookable(notebookable)
    case notebookable.class.to_s
    when 'Bill'
      "OpenCongress: #{notebookable.title_short}"
    when 'Subject'
      "OpenCongress: #{notebookable.term}"
    when 'Person'
      "OpenCongress: #{notebookable.name}"
    when 'Commentary'
      notebookable.title
    end
  end
end
