class ChartsOfc2Controller < ApplicationController
  #line_begin
  def line
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    line_dot = OFC2::Line.new( :values => [9,8,7,6,5,4,3,2,1,12] )
    chart = OFC2::Graph.new
    chart.title= title
    chart << line_dot
    render :text => chart.render
  end
  #line_end

  #line_with_nills_begin
  def line_with_nills
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    line_dot_with_nills = OFC2::Line.new( :values => [1,nil,5,nil,3,nil,nil,nil,1,10] )
    chart = OFC2::Graph.new
    chart.title= title
    chart << line_dot_with_nills
    render :text => chart.render
  end
  #line_with_nills_end

  #lines_with_any_dot_shape_begin
  def lines_with_any_dot_shape
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")

    data = [2,2,2,2,2,2,2,2,2]

    lines = []

    default_dot = OFC2::Dot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    lines << OFC2::Line.new( :values => data, :dot_style => default_dot  )

    default_dot = OFC2::SolidDot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    lines << OFC2::Line.new( :values => data.collect { |item| item + 2 }, :dot_style => default_dot  )

    default_dot = OFC2::HollowDot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    lines << OFC2::Line.new( :values => data.collect { |item| item + 4 }, :dot_style => default_dot  )

    default_dot = OFC2::Star.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    lines << OFC2::Line.new( :values => data.collect { |item| item + 6 }, :dot_style => default_dot  )

    default_dot = OFC2::Bow.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    lines << OFC2::Line.new( :values => data.collect { |item| item + 8 }, :dot_style => default_dot  )

    default_dot = OFC2::Anchor.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    lines << OFC2::Line.new( :values => data.collect { |item| item + 10 }, :dot_style => default_dot  )

    default_dot = OFC2::Anchor.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :sides => 6 )
    lines << OFC2::Line.new( :values => data.collect { |item| item + 12 }, :dot_style => default_dot  )

    custom_data = []
    custom_data << OFC2::Dot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :y =>  16 )
    custom_data << OFC2::SolidDot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :y =>  16 )
    custom_data << OFC2::HollowDot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :y =>  16 )
    custom_data << OFC2::Star.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :y =>  16 )
    custom_data << OFC2::Bow.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :y =>  16 )
    custom_data << OFC2::Anchor.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :y =>  16 )
    custom_data << OFC2::Anchor.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :sides => 6, :y =>  16 )

    lines << OFC2::Line.new( :values => custom_data)

    y = OFC2::YAxis.new(:min => 0, :max => 18, :steps => 2)

    chart = OFC2::Graph.new
    chart.title= title
    lines.each do |line|
      chart << line
    end
    chart.y_axis= y

    render :text => chart.render
  end
  #lines_with_any_dot_shape_end

  #lines_with_any_line_style_begin
  def lines_with_any_line_style
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")

    data = [2,2,2,2,2,2,2,2,2]

    lines = []

    line_style = OFC2::LineStyle.new(:on => 30, :off => 10)
    lines << OFC2::Line.new( :values => data, :line_style => line_style, :colour => '#D4C345', :width => 2  )

    line_style = OFC2::LineStyle.new(:on => 30, :off => 30)
    lines << OFC2::Line.new( :values => data.collect { |item| item + 2 }, :line_style => line_style, :colour =>'#C95653', :width => 1  )

    line_style = OFC2::LineStyle.new(:on => 10, :off => 30)
    lines << OFC2::Line.new( :values => data.collect { |item| item + 4 }, :line_style => line_style, :colour => '#8084FF', :width => 6  )

    y = OFC2::YAxis.new(:min => 0, :max => 8, :steps => 4)

    chart = OFC2::Graph.new
    chart.title= title
    lines.each do |line|
      chart << line
    end
    chart.y_axis= y

    render :text => chart.render
  end
  #lines_with_any_line_style_end

  #bar_begin
  def bar
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    bar = OFC2::Bar.new(:text => 'simple bar', :colour => '#000000')
    bar.values= [9,8,7,6,5,4,3,2,1]
    chart = OFC2::Graph.new
    chart.title= title
    chart << bar
    render :text => chart.render
  end
  #bar_end

  #glass_bar_begin
  def glass_bar
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    bar = OFC2::BarGlass.new(:text => 'simple bar', :colour => '#000000')
    bar.values= [9,8,7,6,5,4,3,2,1]
    chart = OFC2::Graph.new
    chart.title= title
    chart << bar
    render :text => chart.render
  end
  #glass_bar_end

  #bar_round_glass_begin
  def bar_round_glass
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    bar = OFC2::BarRoundGlass.new(:text => 'simple bar', :colour => '#000000')
    bar.values= [9,8,7,6,5,4,3,2,1]
    chart = OFC2::Graph.new
    chart.title= title
    chart << bar
    render :text => chart.render
  end
  #bar_round_glass_end

  #bar_round_begin
  def bar_round
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    bar = OFC2::BarRound.new(:text => 'simple bar', :colour => '#000000')
    bar.values= [9,8,7,6,5,4,3,2,1]
    chart = OFC2::Graph.new
    chart.title= title
    chart << bar
    render :text => chart.render
  end
  #bar_round_end

  #bar_dome_begin
  def bar_dome
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    bar = OFC2::BarDome.new(:text => 'simple bar', :colour => '#000000')
    bar.values= [9,8,7,6,5,4,3,2,1]
    chart = OFC2::Graph.new
    chart.title= title
    chart << bar
    render :text => chart.render
  end
  #bar_dome_end

  #bar_3d_begin
  def bar_3d
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    bar = OFC2::Bar3d.new(:text => 'simple bar', :colour => '#D54C78')
    bar.values = [9,8,7,6,5,4,3,2,1]
    bar.values << OFC2::BarValue.new(:top => 10, :tip => 'Hello<br>#val#')

    x = OFC2::XAxis.new
    x.colour= '#909090'

    x = OFC2::XAxis.new
    x.offset= true
    x.min = 0
    x.max = 9
    x.___3d= 10

    x_labels = OFC2::XAxisLabels.new
    x_labels.steps= 1
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => 0, :max => 10)


    chart = OFC2::Graph.new
    chart.title= title
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #bar_3d_end

  #sketch_bar_begin
  def sketch_bar
    data = []
    0.upto(9) do |i|
      data << 2 + rand(9)
    end

    bar = OFC2::BarSketch.new
    bar.values= data
    bar.colour= '#D54C78'
    bar.offset= 10

    x_labels = OFC2::XAxisLabels.new
    x_labels.steps= 1

    x = OFC2::XAxis.new
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => 0, :max => 12, :steps => 3)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #sketch_bar_end

  #filled_bar_begin
  def filled_bar
    data = []
    0.upto(9) do |i|
      data << 2 + rand(9)
    end

    bar = OFC2::BarFilled.new
    bar.values= data
    bar.colour= '#D54C78'

    x_labels = OFC2::XAxisLabels.new
    x_labels.steps= 1

    x = OFC2::XAxis.new
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => 0, :max => 12, :steps => 3)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #filled_bar_end

  #cylinder_bar_begin
  def cylinder_bar
    data = []
    0.upto(9) do |i|
      data << 2 + rand(9)
    end

    bar = OFC2::BarCylinder.new
    bar.values= data
    bar.colour= '#D54C78'

    x_labels = OFC2::XAxisLabels.new
    x_labels.steps= 1

    x = OFC2::XAxis.new
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => 0, :max => 12, :steps => 3)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #cylinder_bar_end

  #outline_cylinder_bar_begin
  def outline_cylinder_bar
    data = []
    0.upto(9) do |i|
      data << 2 + rand(9)
    end

    bar = OFC2::BarCylinderOutline.new
    bar.values= data
    bar.colour= '#D54C78'

    x_labels = OFC2::XAxisLabels.new
    x_labels.steps= 1

    x = OFC2::XAxis.new
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => 0, :max => 12, :steps => 3)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #outline_cylinder_bar_end

  #horizontal_bar_begin
  def horizontal_bar
    data = []
    0.upto(2) do |i|
      data << OFC2::HBarValue.new(:left => 2 + i, :right => 5 + i)
    end

    bar = OFC2::HBar.new
    bar.values= data
    bar.colour= '#00FF00'

    x_labels = OFC2::XAxisLabels.new
    x_labels.labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

    x = OFC2::XAxis.new
    x.labels = x_labels



    y = OFC2::YAxis.new
    y.offset = true
    y.labels = ["Make garden look sexy","Paint house","Move into house"]

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #horizontal_bar_end

  #stacked_bar_begin
  def stacked_bar

    bar = OFC2::BarStack.new
    bar.values = []
    bar.values << [2.5, 5]
    bar.values << [7.5]
    bar.values << [5, OFC2::BarStackValue.new(:val => 4, :colour => '#ff0000')]
    bar.values << [2, 2, 2, 2, OFC2::BarStackValue.new(:val => 2, :colour => '#ff00ff', :tip => 'custop tip<br>#val# of #total#')]
    bar.colour= '#00FF00'
    bar.tip = 'X label [#x_label#], Value [#val#]<br>Total [#total#]'

    keys = []
    keys << OFC2::BarStackKey.new( :colour => '#ff0000', :text => 'red', :font_size => 13 )
    keys << OFC2::BarStackKey.new( :colour => '#ff00ff', :text => 'pink', :font_size => 13 )
    keys << OFC2::BarStackKey.new( :colour => '#00FF00', :text => 'green', :font_size => 13 )
    bar.set_keys keys

    x_labels = OFC2::XAxisLabels.new
    x_labels.steps= 1
    x_labels.labels = ['a', 'b', 'c', 'd']

    x = OFC2::XAxis.new
    x.set_labels x_labels

    y = OFC2::YAxis.new

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #stacked_bar_end

  #area_begin
  def area
    data = []
    x = 0
    y = 20
    while x<y
      data << Math.tan(x)
      x+=0.4
    end

    area = OFC2::Area.new(:values => data, :fill => '#FA00fA', :text =>'tangens', :colour => '#000000' )

    x = OFC2::XAxis.new
    x.steps= 5
    x.min = 0
    x.max = 50

    x_labels = OFC2::XAxisLabels.new
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => -35, :max => 20, :steps => 5)


    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart.x_axis= x
    chart.y_axis= y
    chart << area
    render :text => chart.render
  end
  #area_end

  #area_withany_dot_shape_begin
  def area_with_any_dot_shape
    data = [1,2,3,4,5,6,5,4,3,2,1]

    areas = []

    default_dot = OFC2::Anchor.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12, :sides => 6 )
    areas << OFC2::Area.new(:values => data.collect { |item| item + 96 }, :fill => '#FFC0C0', :text =>'anchor 6 sides', :colour => '#FFC0C0', :dot_style => default_dot   )

    default_dot = OFC2::Anchor.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    areas << OFC2::Area.new(:values => data.collect { |item| item + 80 }, :fill => '#FFA0A0', :text =>'anchor', :colour => '#FFA0A0', :dot_style => default_dot   )

    default_dot = OFC2::Bow.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    areas << OFC2::Area.new(:values => data.collect { |item| item + 64 }, :fill => '#FF8080', :text =>'bow', :colour => '#FF8080', :dot_style => default_dot   )

    default_dot = OFC2::Star.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    areas << OFC2::Area.new(:values => data.collect { |item| item + 48 }, :fill => '#FF6060', :text =>'star', :colour => '#FF6060', :dot_style => default_dot   )

    default_dot = OFC2::HollowDot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    areas << OFC2::Area.new(:values => data.collect { |item| item + 32 }, :fill => '#FF4040', :text =>'hollow dot', :colour => '#FF4040', :dot_style => default_dot   )

    default_dot = OFC2::SolidDot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    areas << OFC2::Area.new(:values => data.collect { |item| item + 16 }, :fill => '#FF2020', :text =>'solid dot', :colour => '#FF2020', :dot_style => default_dot   )

    default_dot = OFC2::Dot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    areas << OFC2::Area.new(:values => data, :fill => '#FF0000', :text =>'dot', :colour => '#FF0000', :dot_style => default_dot   )

    x = OFC2::XAxis.new
    x.steps= 2
    x.min = 0
    x.max = 10

    x_labels = OFC2::XAxisLabels.new
    x.set_labels x_labels

    y = OFC2::YAxis.new(:min => 0, :max => 110, :steps => 50)


    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart.x_axis= x
    chart.y_axis= y
    areas.each do |area|
      chart << area
    end
    render :text => chart.render
  end
  #area_with_any_dot_shape_end

  #pie_begin
  def pie
    data_1 = [
      OFC2::PieValue.new(:value => 35,  :label => 'Mozilla', :font_size => 35),
      OFC2::PieValue.new(:value => 25, :label => 'Safari', :font_size => 25),
      OFC2::PieValue.new(:value => 30, :label =>  'Opera', :font_size => 30),
      OFC2::PieValue.new(:value => 10,  :label => 'IE', :font_size => 10)
    ]

    pie = OFC2::Pie.new(
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => '#val# of #total#<br>#percent# of 100%',
      :label_colour => '#FF00FF',
      :values => data_1
    )
    colours  = []
    0.upto(4) do |i|
      colours  << "##{i + 1}#{10-i}#{i+4}#{10-i}#{i+5}#{10-i}"
    end
    pie.colours = colours

    chart = OFC2::Graph.new
    chart.title= OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << pie

    render :text => chart.render
  end
  #pie_end

  #pie_large_begin
  def pie_large
    data_1 = []
    40.upto(80) do |i|
      data_1 << OFC2::PieValue.new(:value => i,  :label => i, :font_size => 10)
      i += 10
    end

    pie = OFC2::Pie.new(
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => '#val# of #total#<br>#percent# of 100%',
      :label_colour => '#FF00FF',
      :values => data_1
    )
    colours  = []
    0.upto(4) do |i|
      colours  << "##{i + 1}#{10-i}#{i+4}#{10-i}#{i+5}#{10-i}"
    end
    pie.colours = colours

    chart = OFC2::Graph.new
    chart.title= OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << pie

    render :text => chart.render
  end
  #pie_large_end

  #pie_without_labels_begin
  def pie_without_labels
    data_1 = [
      OFC2::PieValue.new(:value => 35,  :label => 'Mozilla', :font_size => 35),
      OFC2::PieValue.new(:value => 25, :label => 'Safari', :font_size => 25),
      OFC2::PieValue.new(:value => 30, :label =>  'Opera', :font_size => 30),
      OFC2::PieValue.new(:value => 10,  :label => 'IE', :font_size => 10)
    ]

    pie = OFC2::Pie.new(
      :no_labels => true,
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => '#label#<br>#val# of #total#<br>#percent# of 100%',
      :values => data_1
    )
    colours  = []
    0.upto(4) do |i|
      colours  << "##{i + 1}#{10-i}#{i+4}#{10-i}#{i+5}#{10-i}"
    end
    pie.colours = colours

    chart = OFC2::Graph.new
    chart.title= OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << pie

    render :text => chart.render
  end
  #pie_without_labels_end

  #pie_tip_begin
  def pie_tip
    data_1 = [
      OFC2::PieValue.new(:value => 35,  :label => 'Mozilla', :font_size => 35),
      OFC2::PieValue.new(:value => 25, :label => 'Safari', :font_size => 25),
      OFC2::PieValue.new(:value => 30, :label =>  'Opera', :font_size => 30),
      OFC2::PieValue.new(:value => 10,  :label => 'IE', :font_size => 10)
    ]

    pie = OFC2::Pie.new(
      :no_labels => true,
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => 'val : #val#<br>total : #total#<br>percent : #percent#<br>label : #label#<br>extra text',
      :values => data_1
    )
    colours  = []
    0.upto(4) do |i|
      colours  << "##{i + 1}#{10-i}#{i+4}#{10-i}#{i+5}#{10-i}"
    end
    pie.colours = colours

    chart = OFC2::Graph.new
    chart.title= OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << pie

    render :text => chart.render
  end
  #pie_tip_end

  #pie_on_click_event_begin
  def pie_on_click_event
    data_1 = [
      OFC2::PieValue.new(:value => 35,  :label => 'Mozilla', :font_size => 35, :on_click => "alert('mozilla clicked!')"),
      OFC2::PieValue.new(:value => 25, :label => 'Safari', :font_size => 25),
      OFC2::PieValue.new(:value => 30, :label =>  'Opera', :font_size => 30),
      OFC2::PieValue.new(:value => 10,  :label => 'IE', :font_size => 10)
    ]

    pie = OFC2::Pie.new(
      :on_click => "alert('pie clicked!')",
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => '#label#<br>#val# of #total#<br>#percent# of 100%',
      :values => data_1
    )
    colours  = []
    0.upto(4) do |i|
      colours  << "##{i + 1}#{10-i}#{i+4}#{10-i}#{i+5}#{10-i}"
    end
    pie.colours = colours

    chart = OFC2::Graph.new
    chart.title= OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << pie

    render :text => chart.render
  end
  #pie_on_click_event_end

  #pie_radius_begin
  def pie_radius
    data_1 = [
      OFC2::PieValue.new(:value => 35,  :label => 'Mozilla', :font_size => 35),
      OFC2::PieValue.new(:value => 25, :label => 'Safari', :font_size => 25),
      OFC2::PieValue.new(:value => 30, :label =>  'Opera', :font_size => 30),
      OFC2::PieValue.new(:value => 10,  :label => 'IE', :font_size => 10)
    ]
    data_2 = [
      OFC2::PieValue.new(:value => 35,  :label => 'Mozilla'),
      OFC2::PieValue.new(:value => 25, :label => 'Safari'),
      OFC2::PieValue.new(:value => 30, :label =>  'Opera'),
      OFC2::PieValue.new(:value => 10,  :label => 'IE'),
    ]

    pie = OFC2::Pie.new(
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => '#label#<br>#val# of #total#<br>#percent# of 100%',
      :values => data_1,
      :radius => 80
    )
    under_pie = OFC2::Pie.new(
      :no_labels => true,
      :gradient_fill => true,
      :alpha => 0.8,
      :start_angle => 35,
      :animate =>  [OFC2::PieFade.new, OFC2::PieBounce.new],
      :tip => '#label#<br>#val# of #total#<br>#percent# of 100%',
      :values => data_2,
      :radius => 50
    )
    colours  = []
    0.upto(4) do |i|
      colours  << "##{i + 1}#{10-i}#{i+4}#{10-i}#{i+5}#{10-i}"
    end
    pie.colours = colours

    chart = OFC2::Graph.new
    chart.title= OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << under_pie
    chart << pie

    render :text => chart.render
  end
  #pie_radius_end

  #scatter_begin
  def scatter

    data_2 = []
    x = 0
    y = 360
    while x<y
      data_2 << OFC2::ScatterValue.new(:x =>"%6.2f" % Math.sin(x/Math::RAD2DEG), :y => "%6.2f" % (Math.cos(x/Math::RAD2DEG)+0.5))
      data_2 << OFC2::ScatterValue.new(:x =>"%6.2f" % (Math.sin(x/Math::RAD2DEG)-2.3), :y => "%6.2f" % (Math.cos(x/Math::RAD2DEG)+0.5))
      data_2 << OFC2::ScatterValue.new(:x =>"%6.2f" % (Math.sin(x/Math::RAD2DEG)+2.3), :y => "%6.2f" % (Math.cos(x/Math::RAD2DEG)+0.5))
      x+=15
    end
    data_3 = []
    x = 0
    y = 360
    while x<y
      data_3 << OFC2::ScatterValue.new(:x =>"%6.2f" % (Math.sin(x/Math::RAD2DEG)+1.2), :y => "%6.2f" % (Math.cos(x/Math::RAD2DEG)-0.5))
      data_3 << OFC2::ScatterValue.new(:x =>"%6.2f" % (Math.sin(x/Math::RAD2DEG)-1.2), :y => "%6.2f" % (Math.cos(x/Math::RAD2DEG)-0.5))
      x+=15
    end


    default_dot = OFC2::SolidDot.new( :colour => '#FF0000', :dot_size => 4, :halo_size =>4 )
    circle = OFC2::Scatter.new(:colour => '#D600FF')
    circle.dot_style = default_dot
    circle.values= data_2

    default_dot = OFC2::Star.new( :colour => '#FF0000', :dot_size => 4, :halo_size =>4 )
    circle2 = OFC2::Scatter.new(:colour => '#D600FF')
    circle2.dot_style = default_dot
    circle2.values= data_3

    x = OFC2::XAxis.new(:min => -3, :max => 3)

    y = OFC2::YAxis.new(:min => -3, :max => 3)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << circle
    chart << circle2
    chart.x_axis= x
    chart.y_axis= y

    render :text => chart.render
  end
  #scatter_end

  #scatter_line_begin
  def scatter_line

    data_1 = []
    20.times do |i|
      data_1 << OFC2::ScatterValue.new(:x =>(i - 10), :y => (i - 10 - rand(5)))
    end

    data_2 = []
    20.times do |i|
      data_2 << OFC2::ScatterValue.new(:x =>(i - 10 - rand(5)), :y => (i - 10))
    end

    data_3 = []
    20.times do |i|
      data_3 << OFC2::ScatterValue.new(:x =>(i - 10 - rand(5)), :y => (i))
    end


    default_dot = OFC2::SolidDot.new( :colour => '#FF0000', :dot_size => 4, :halo_size =>4 )
    line = OFC2::ScatterLine.new(:colour => '#D600FF', :dot_style => default_dot, :values => data_1,
      :stepgraph => 'horizontal', :text => 'stepgraph horizontal')

    default_dot = OFC2::SolidDot.new( :colour => '#FFFF00', :dot_size => 4, :halo_size =>4 )
    line2 = OFC2::ScatterLine.new(:colour => '#D6AAFF', :dot_style => default_dot, :values => data_2,
      :stepgraph => 'vertical', :text => 'stepgraph vertical')

    default_dot = OFC2::SolidDot.new( :colour => '#F00F00', :dot_size => 4, :halo_size =>4 )
    line3 = OFC2::ScatterLine.new(:colour => '#D6AA00', :dot_style => default_dot, :values => data_3,
      :stepgraph => nil, :text => 'empty stepgraph')


    x = OFC2::XAxis.new(:min => -10, :max => 10)

    y = OFC2::YAxis.new(:min => -10, :max => 10)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << line
    chart << line2
    chart << line3
    chart.x_axis= x
    chart.y_axis= y

    render :text => chart.render
  end
  #scatter_line_end

  #mix_line_bar_begin
  def mix_line_bar
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    line_dot = OFC2::Line.new(:text => 'line label', :colour => '#FF0000')
    line_dot.tip = '#val#<br>Your text here for line'
    line_dot.values= [9,8,7,6,5,4,3,2,1]

    bar = OFC2::Bar.new(:text => 'bar label', :colour => '#0000FC')
    bar.tip = '#val#<br>Your text here for bar'
    bar.values= [9,8,7,6,5,4,3,2,1].reverse
    #    data = []
    #    0.upto(9) do |i|
    #      data << OFC2::Value.new(i,'#00FF00',"main tip #{i}<br>extra tip")
    #    end
    #    bar.values= data

    chart = OFC2::Graph.new
    chart.title= title
    chart << line_dot
    chart << bar
    render :text => chart.render
  end
  #mix_line_bar_end

  #mix_advanced_tooltip_begin
  def mix_advanced_tooltip
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")

    default_dot = OFC2::Dot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    line_dot = OFC2::Line.new
    line_dot.dot_style = default_dot
    line_dot.set_tip('#val#<br>Your text here for line')
    line_dot.text= 'actual sales'
    line_dot.font_size= '12'
    line_dot.colour= '#FF0000'
    line_dot.dot_size= 5

    bar = OFC2::Bar.new
    bar.tip = '#val#<br>Your text here for bar'
    bar.text= 'forecast sales'
    bar.font_size= '12'
    bar.colour= '#00FF00'

    line_values= []
    bar_values= []
    max = 12

    0.upto(max) do |i|
      actual_sales = rand(max)
      forecast_sales = rand(max)

      _tooltip = "Summer Sales Blitz<br>actual sales: #{actual_sales}<br>forecast sales:#{forecast_sales}"

      line_values << OFC2::Dot.new(:value => actual_sales, :colour => '#FF0000', :tip => _tooltip)
      bar_values << OFC2::BarValue.new(:top => forecast_sales, :colour => '#00FF00', :tip =>_tooltip)
    end

    line_dot.values= line_values
    bar.values= bar_values

    chart = OFC2::Graph.new
    chart.title= title
    chart << line_dot
    chart << bar

    tooltip = OFC2::Tooltip.new
    tooltip.hover
    tooltip.stroke=5
    tooltip.shadow=true
    tooltip.colour="#e2ff60"
    tooltip.background_colour="#FFFFFF"
    tooltip.title="{font-size: 14px; font-weight: bold; color: #000000;}"
    tooltip.body="{font-size: 10px; font-weight: bold; color: #707070;}"

    chart.tooltip = tooltip

    y = OFC2::YAxis.new(:min => 0, :max => max, :steps => max/2)

    chart.y_axis= y

    chart.bg_colour= '#FFFFFF'

    render :text => chart.render
  end
  #mix_advanced_tooltip_end

  #mix_advanced_scaled_axis_begin
  def mix_advanced_scaled_axis
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    line_dot = OFC2::Line.new( :values => [9,8,7,6,5,4,3,2,1,12] )
    chart = OFC2::Graph.new
    chart.title= title

    x_labels = OFC2::XAxisLabels.new
    #        x_labels.rotate= 'vertical'
    x_labels.rotate= 'diagonal'


    x = OFC2::XAxis.new
    x.colour= '#D7E4A3'
    x.grid_colour= '#A7E4A3'
    # Add the X Axis Labels to the X Axis
    x.labels= x_labels

    y_axis = OFC2::YAxis.new(:min => 0, :max => 20)
    y_axis.colour= '#AAAA00'
    y_axis.grid_colour= '#00FFF0'

    chart.x_axis= x
    chart.y_axis= y_axis
    chart.y_axis_right= y_axis

    chart << line_dot
    render :text => chart.render
  end
  #mix_advanced_scaled_axis_end

  #mix_advanced_legends_begin
  def mix_advanced_legends
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")

    default_dot = OFC2::Dot.new( :colour => '#FF0000', :dot_size => 10, :halo_size =>12 )
    line_dot = OFC2::Line.new
    line_dot.dot_style = default_dot
    line_dot.set_tip('#val#<br>Your text here for line')
    line_dot.text= 'actual sales'
    line_dot.font_size= 12
    line_dot.colour= '#FF0000'
    line_dot.dot_size= 5

    bar = OFC2::Bar.new
    bar.set_tip('#val#<br>Your text here for bar')
    bar.text= 'forecast sales'
    line_dot.font_size= '12'
    bar.colour= '#00FF00'

    line_values= []
    bar_values= []
    x_labels_text = []
    y_labels_text = []
    max = 12

    0.upto(max) do |i|
      actual_sales = rand(max)
      forecast_sales = rand(max)
      line_values << OFC2::SolidDot.new(:value => actual_sales, :colour => '#FF0000', :tip => "actual sales: #{actual_sales}")
      bar_values << OFC2::BarValue.new(:top => forecast_sales, :colour => '#00FF00', :tip => "forecast sales:#{forecast_sales}")
      x_labels_text << "label #{i}"
      y_labels_text << "y label #{i}"
    end

    line_dot.values= line_values
    bar.values= bar_values


    x_labels = OFC2::XAxisLabels.new
    #    x_labels.steps= 1
    x_labels.rotate= 'vertical'
    x_labels.rotate= 'diagonal'
    #    x_labels.colour = '#FF2ACB'
    #    x_labels.size = 12

    x_labels_text[7] = OFC2::XAxisLabel.new(:text => '7', :colour => '#0000FF', :size => 20, :rotate => 90)
    x_labels_text[8] = OFC2::XAxisLabel.new(:text => 'eight', :colour => '#8C773E', :size => 16, :rotate => 70)
    x_labels_text[9] = OFC2::XAxisLabel.new(:text => 'nine',  :colour => '#2683CF', :size => 14, :visible => false)

    x_labels.labels= x_labels_text

    x = OFC2::XAxis.new
    x.colour= '#D7E4A3'
    x.grid_colour= '#A7E4A3'
    x.offset= true
    x.stroke = 10
    x.tick_height = 20
    # Add the X Axis Labels to the X Axis
    x.labels= x_labels

    x_legend = OFC2::XLegend.new( :text => "labels from 0 to #{max}" )
    x_legend.style= '{font-size: 20px; color: #FF8877}'

    y_legend = OFC2::YLegend.new( :text =>"Y description" )
    y_legend.style= '{font-size: 20px; color: #778877}'

    y_legend_right = OFC2::YLegend.new( :text =>"Y right description" )
    y_legend_right.style= '{font-size: 20px; color: #887788}'

    y_axis = OFC2::YAxis.new(:min => 0, :max => max, :steps => max/2)
    y_axis.stroke= 3
    y_axis.colour= '#AAAA00'
    y_axis.grid_colour= '#00FFF0'
    y_axis.tick_length= 20
    #    y_axis.steps= 2
    y_axis.labels= y_labels_text

    chart = OFC2::Graph.new
    chart.title= title

    chart.x_axis= x
    chart.x_legend=x_legend
    chart.y_legend=y_legend
    chart.y2_legend=y_legend_right
    chart.y_axis= y_axis
    chart.y_axis_right= y_axis
    chart.bg_colour= '#FFFFFF'

    chart << line_dot
    chart << bar

    render :text => chart.render
  end
  #mix_advanced_legends_end

  #mix_advanced_many_hbar_begin
  def mix_advanced_many_hbar

    bar = OFC2::HBar.new
    bar.values = []
    bar.values << OFC2::HBarValue.new(:left => 0, :right => 3, :tip => 'schedule: 2 actual: 3')
    bar.values << OFC2::HBarValue.new(:left => 0, :right => 3, :tip => 'schedule: 2 actual: 3')
    bar.values << OFC2::HBarValue.new(:left => 3, :right => 4, :tip => 'schedule: 3 actual: 4')
    bar.values << OFC2::HBarValue.new(:left => 4, :right => 5, :tip => 'schedule: 4 actual: 5')
    bar.colour= '#FEC13F'
    bar.text = 'actual'

    bar2 = OFC2::HBar.new
    bar2.values= [OFC2::HBarValue.new(:left => 3, :right => 4, :tip => 'schedule: 3 actual: 4')]
    bar2.colour= '#FF0000'
    bar2.text = 'schedule'

    bar3 = OFC2::HBar.new
    bar3.values= [OFC2::HBarValue.new(:left => 4, :right => 5, :tip => 'schedule: 4 actual: 5')]
    bar3.colour= '#0000FF'
    bar3.text = 'traffic'


    x = OFC2::XAxis.new
    x.min = 0
    x.max = 5

    y = OFC2::YAxis.new
    y.labels = []
    Date.today.upto(Date.today + 3) do |date|
      y.labels << date.to_s(:db)
    end

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << bar3
    chart << bar2
    chart << bar
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #mix_advanced_many_hbar_end

  #  #mix_advanced_shapes_begin
  #  def mix_advanced_shapes
  #
  #    # add line beause we can't set text and font_size for shape
  #    # notice there is empty values table
  #    line = OFC2::Line.new(:text => 'schedule', :font_size => 10, :values => [], :colour => '#FF0000')
  #
  #    bar = OFC2::HBar.new
  #    bar.values= [OFC2::HBarValue.new(:left => 0, :right => 5, :tip => 'schedule: 2 actual: 3')]
  #    bar.colour= '#FEC13F'
  #    bar.text = 'actual'
  #
  #    shape = OFC2::Shape.new(:colour => '#FF0000')
  #    shape.values = []
  #    shape.values << OFC2::ShapePoint.new(:x => 0.0, :y => 0.8)
  #    shape.values << OFC2::ShapePoint.new(:x => 0.0, :y => 0.4)
  #    shape.values << OFC2::ShapePoint.new(:x => 2.0, :y => 0.4)
  #    shape.values << OFC2::ShapePoint.new(:x => 2.0, :y => 0.8)
  #
  #    x = OFC2::XAxis.new
  #    x.min = 0
  #    x.max = 5
  #
  #    y = OFC2::YAxis.new
  #    #          y.set_offset true
  #    y.labels = ["",""]
  #
  #    chart = OFC2::Graph.new
  #    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
  #    chart << bar
  #    chart << shape
  #    chart << line
  #    chart.x_axis= x
  #    chart.y_axis= y
  #    render :text => chart.render
  #  end
  #  #mix_advanced_shapes_end

  #mix_advanced_draw_shape_begin
  def mix_advanced_draw_shape
    shape = OFC2::Shape.new(:colour => '#FF0000')
    shape.values = []
    shape.values << OFC2::ShapePoint.new(:x => 1.0, :y => -0.3)
    shape.values << OFC2::ShapePoint.new(:x => 2.0, :y => 0.0)
    shape.values << OFC2::ShapePoint.new(:x => 3.0, :y => 0.3)
    shape.values << OFC2::ShapePoint.new(:x => 4.0, :y => -0.3)
    shape.values << OFC2::ShapePoint.new(:x => 5.0, :y => 0.0)

    shape2 = OFC2::Shape.new(:colour => '#00FF00')
    shape2.values = []
    shape2.values << OFC2::ShapePoint.new(:x => 0.0, :y => 0.4)
    shape2.values << OFC2::ShapePoint.new(:x => 0.0, :y => -0.4)
    shape2.values << OFC2::ShapePoint.new(:x => 2.0, :y => -0.4)
    shape2.values << OFC2::ShapePoint.new(:x => 2.0, :y => 0.4)

    x = OFC2::XAxis.new
    x.min = 0
    x.max = 5

    y = OFC2::YAxis.new
    y.set_offset true
    y.labels = ["y_label"]

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart << shape
    chart << shape2
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end
  #mix_advanced_draw_shape_end

  #radar_begin
  def radar
    default_dot = OFC2::HollowDot.new(:colour => '#45909F', :dot_size =>5)

    area = OFC2::Area.new(
      :values => [3, 4, 5, 4, 3, 3, 2.5],
      :fill => '#45909F',
      :text =>'radar',
      :colour => '#45909F',
      :width => 1,
      :dot_style => default_dot,
      :fill_alpha => 0.4,
      :loop => true #important!, join last point with first
    )

    x_labels = OFC2::RadarAxisLabels.new
    x_labels.colour = '#9F819F'
    x_labels.labels = %w(0 1 2 3 4 5)

    x = OFC2::RadarAxis.new
    x.max = 5
    x.colour = '#EFD1EF'
    x.grid_colour = '#EFD1EF'
    x.labels = x_labels

    tooltip = OFC2::Tooltip.new(:mouse => 1)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart.radar_axis= x
    chart.tooltip = tooltip
    chart << area
    render :text => chart.render
  end
  #radar_end

  #radar_lines_begin
  def radar_lines

    gold = OFC2::Line.new(
      :values => [3, 4, 5, 4, 3, 3, 2.5],
      :colour => '#FBB829',
      :width => 1,
      :dot_style => OFC2::HollowDot.new(:colour => '#45909F', :dot_size =>4),
      :tip => "Gold<br>#val#",
      :text => "Mr. Gold"
      #      :loop => true #important!, join last point with first, ommit here to show how it's look when loop  not set
    )

    purple = OFC2::Line.new(
      :values => [2, 2, 2, 2, 2, 2, 2],
      :colour => '#8000FF',
      :width => 1,
      :dot_style => OFC2::Star.new(:colour => '#8000FF', :dot_size =>4),
      :tip => "Purple<br>#val#",
      :text => "Mr. Purple",
      :loop => true #important!, join last point with first
    )

    labels = OFC2::RadarAxisLabels.new
    labels.colour = '#9F819F'
    labels.labels = ['Zero', '', '', 'Middle', '', 'High']

    spoke_labels = OFC2::RadarSpokeLabels.new(
      :labels => ['Strength', 'Smarts', 'Sweet<br>Tooth', 'Armour', 'Max Hit Points', 'Looks Like a Monkey'],
      :colour => '#9F819F'
    )

    x = OFC2::RadarAxis.new
    x.max = 5
    x.colour = '#DAD5E0'
    x.grid_colour = '#DAD5E0'
    x.labels = labels
    x.spoke_labels = spoke_labels

    tooltip = OFC2::Tooltip.new(:mouse => 1)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart.radar_axis= x
    chart.tooltip = tooltip
    chart << gold
    chart << purple
    render :text => chart.render
  end
  #radar_lines_end

  #radar_minimal_view_begin
  def radar_minimal_view

    spokes = []
    'a'.upto('p') do |letter|
      spokes << letter
    end
    values = []
    [30,50,60,70,80,90,100,115,130,115,100,90,80,70,60,50].each_with_index do |number, index|
      values << OFC2::SolidDot.new(:colour => '#D41E47', :tip => "#val#<br>Spoke: #{spokes[index]}", :value => number)
    end

    line = OFC2::Line.new(
      :values => values,
      :colour => '#FBB829',
      :width => 2,
      :text => "Hearts",
      :font_size => 10,
      :loop => true #important!, join last point with first
    )

    x = OFC2::RadarAxis.new
    x.max = 150
    x.steps = 10
    x.colour = '#DAD5E0'
    x.grid_colour = '#EFEFEF'

    tooltip = OFC2::Tooltip.new(:mouse => 1)

    chart = OFC2::Graph.new
    chart.title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    chart.radar_axis= x
    chart.bg_colour = '#ffffff'
    chart.tooltip = tooltip

    chart << line
    render :text => chart.render
  end
  #radar_minimal_view_end

  #mix_line_with_y_axis_begin
  def mix_line_with_y_axis
    title = OFC2::Title.new( :text => action_name.humanize , :style => "{font-size: 14px; color: #b50F0F; text-align: center;}")
    line_dot = OFC2::Line.new( :values => [900,800,700,1600,2500,4000,3300,1200,100,1200] )

    y_axis = OFC2::YAxis.new(:min => 0, :max => 4000, :steps => 1000)

    chart = OFC2::Graph.new
    chart.title= title
    chart.y_axis= y_axis

    chart << line_dot
    render :text => chart.render
  end
  #mix_line_with_y_axis_end

end
