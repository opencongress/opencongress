module NotebookVideosHelper

  def div_height(y)
    ymod = y % 24
    div_y = (24 - ymod) + y
    return div_y
  end
end
