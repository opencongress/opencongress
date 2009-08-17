class Documentations::GraphController < ApplicationController
  def index
    chart = OFC2::Graph.new
    @simple_chart = ofc2_inline(650,200,chart,'inline_line')
  end
  def title
    title = OFC2::Title.new

    chart = OFC2::Graph.new(:title => title)

    @simple_chart = ofc2_inline(650,200,chart,'inline_line')
  end

  def elements
    title = OFC2::Title.new( :text => 'elements')
    line_dot = OFC2::Line.new( :values => [6,5,4,2,1] )
    chart = OFC2::Graph.new(:title => title)
    chart << line_dot

    @simple_chart_1 = ofc2_inline(650,200,chart,'inline_line')

    title = OFC2::Title.new( :text => 'elements')
    line_dot = OFC2::Line.new( :values => [6,5,4,2,1] )
    chart = OFC2::Graph.new(:title => title, :elements => [line_dot])
    @simple_chart_2 = ofc2_inline(650,200,chart,'inline_line_2')
  end
  def add_element
    title = OFC2::Title.new( :text => 'elements')
    line_dot = OFC2::Line.new( :values => [6,5,4,2,1] )
    line_dot_2 = OFC2::Line.new( :values => [6,5,4,2,1].reverse )
    chart = OFC2::Graph.new(:title => title)
    chart << line_dot
    chart.add_element(line_dot_2)

    @simple_chart_1 = ofc2_inline(650,200,chart,'inline_line')
  end

  def radar_axis
  end

  def x_axis
    title = OFC2::Title.new
    line_dot = OFC2::Line.new( :values => [6,5,4,2,1] )
    chart = OFC2::Graph.new(:title => title)
    chart << line_dot
    @no_xaxis = ofc2_inline(650,200,chart,'no_xaxis')


    title = OFC2::Title.new
    line_dot = OFC2::Line.new( :values => [6,5,4,2,1] )
    x = OFC2::XAxis.new
    chart = OFC2::Graph.new(:title => title)
    chart.x_axis = x
    chart << line_dot
    @empty_xaxis = ofc2_inline(650,200,chart,'empty_xaxis')


    title = OFC2::Title.new
    line_dot = OFC2::Line.new( :values => [6,5,4,2,1] )
    x = OFC2::XAxis.new(
      :colour => '#D7E4A3',
      :grid_colour => '#A7E4A3',
      :offset => true,
      :stroke => 10,
      :tick_height => 20
    )
    chart = OFC2::Graph.new(:title => title)
    chart.x_axis = x
    chart << line_dot
    @complete_xaxis = ofc2_inline(650,200,chart,'complete_xaxis')

  end

  def y_axis
  end

  def y_axis_right
  end

  def x_legend
  end

  def y_legend
  end

  def y2_legend
  end

  def bg_colour
  end
end
