class ChartsOfc2Controller < ApplicationController
  #inline_line_begin
  def inline_line
    title = OFC2::Title.new(
      :text => action_name.humanize ,
      :style => "{font-size: 14px; color: #b50F0F; text-align: center;}"
    )
    line_dot = OFC2::Line.new
    line_dot.values= [9,8,7,6,5,4,3,2,1]
    line_dot.colour = '#FFAAFF'

    line_dot_2 = OFC2::Line.new
    line_dot_2.values= [9,8,7,6,5,4,3,2,1].reverse

    chart = OFC2::Graph.new
    chart.title= title

    chart << line_dot
    chart << line_dot_2

    @graph = ofc2_inline(650,300,chart,'inline_line')
  end
  #inline_line_end

  #inline_many_line_begin
  def inline_many_line
    title = OFC2::Title.new(
      :text => action_name.humanize ,
      :style => "{font-size: 14px; color: #b50F0F; text-align: center;}"
    )
    line_dot = OFC2::Line.new
    line_dot.values= [9,8,7,6,5,4,3,2,1]
    line_dot.colour = '#00FF00'
    chart = OFC2::Graph.new
    chart.title= title
    chart << line_dot

    @graph = ofc2_inline(650,300,chart,'inline_line')

    bar = OFC2::Bar.new
    bar.values= [9,8,7,6,5,4,3,2,1]
    bar.colour = '#FF0000'
    chart = OFC2::Graph.new
    chart.title= title
    chart << bar

    @seccond_graph = ofc2_inline(650,300,chart,'inline_line_2')
  end
  #inline_many_line_end
end
