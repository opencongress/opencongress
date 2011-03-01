module WatchdogsHelper

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

  def get_label
    @label = ""
    if @type
      case @type
        when 'NotebookFile'
          @label += 'Files '
        when 'NotebookNote'
          @label += 'Notes '
        when 'NotebookLink'
          @label += 'Links '
        when 'NotebookVideo'
          @label += 'Videos '
      end
    else @label += 'All Items '
    end
    if @tag
      @label += "Tagged With '#{@tag}'"
    end
    return @label
  end
      
  def image_for(file, size = '') 
    image_tag("#{Settings.base_url}#{file.public_filename(size)}")
  end
    
  def div_height(y)
    ymod = y % 24
    div_y = (24 - ymod) + y
    return div_y
  end

  def is_on(type)
    if @type == type
      "on"
    else
      "off"
    end
  end
  
end
