module OFC2
  # specjal module included in each class
  # with that module we add to_hash method
  # there is also a method_missing which allow user to set/get any instance variable
  # if user try to get not setted instance variable it return nil and generate a warn
  module OWJSON
    # return a hash of instance values
    def to_hash
      self.instance_values
    end
    alias :to_h :to_hash

    # if You use rails older that 2.3  probably  you have to uncomment that method and add "config.gem 'json'" in config/enviroment.rb file
    # otherwise to_json method will not work propertly
    #    # You can pass options to to_json method, but remember that they have no effects!!!
    #    # argument 'options' is for rails compability
        def to_json(options = {})
          to_hash.to_json
        end

    # method_missing handle setting and getting instance variables
    # You can set variable in two ways:
    # 1. variable_name = value
    # 1. set_variable_name(value)
    # you can get only  alredy setted variables, otherwise warnig is logged and return nil
    def method_missing(method_id, *arguments)
      a = arguments[0] if arguments and arguments.size > 0
      method = method_id.to_s
      if method =~ /^(.*)(=)$/
        self.instance_variable_set("@#{$1.gsub('_','__')}", a)
      elsif method =~ /^(set_)(.*)$/
        self.instance_variable_set("@#{$2.gsub('_','__')}", a)
      elsif self.instance_variable_defined?("@#{method_id.to_s.gsub('_','__')}")
        self.instance_variable_get("@#{method_id.to_s.gsub('_','__')}") # that will be return instance variable value or nil, handy
      else
        warning = <<-EOF
          !!! there is no instance variable named #{method_id} !!!
          - if You want to set instance variable use variable= or set_variable(var) methods
          - if You want to get variable call object for variable: obj.variable
          - You can call only for variables You set before
        EOF
        warn(warning)
        nil
      end
    end
  end

  # include methods to controller
  def self.included(controller)
    controller.helper_method(:ofc2, :ofc2_inline)
  end

  # generate a ofc object using Graph object, it's more handy than ofc2 method
  #  +width+ width for div
  #  +height+ height for div
  #  +graph+ a OFC2::Graph object
  #  +base+ uri for graph, default '/', not used in this method, go to ofc2 method for details
  #  +id+ id for div with graph, default Time.now.usec
  #  +swf_base+ uri for swf file, default '/'
  def ofc2_inline(width, height, graph, id=Time.now.usec, swf_base='/')
    div_name = "flashcontent_#{id}"
    <<-EOF
      <div id="#{div_name}"></div>
      <script type="text/javascript">

        function #{div_name}_data(){
          return '#{graph.render}';
        };

        swfobject.embedSWF(
          '#{swf_base}open-flash-chart.swf', '#{div_name}',
          '#{width}', '#{height}','9.0.0', 'expressInstall.swf',
          {'get-data':'#{div_name}_data'} );

      </script>
    EOF
  end

  # generate a ofc object using data from url
  #  +width+ width for div
  #  +height+ height for div
  #  +url+ an url which return data in json format, if you use url_for method to set url param the base param must be set to '' (empty string)
  #  +base+ uri for graph, default '/'
  #  +id+ id for div with graph, default Time.now.usec
  #  +swf_base+ uri for swf file, default '/'
  def ofc2(width, height, url, base='/', id =Time.now.usec, swf_base='/')
    url = CGI::escape(url)
    div_name = "flashcontent_#{id}"
    <<-EOF
      <div id='#{div_name}'></div>
      <script type="text/javascript">
        swfobject.embedSWF(
        "#{swf_base}open-flash-chart.swf","#{div_name}",
        "#{width}", "#{height}", "9.0.0", "expressInstall.swf",
        {"data-file":"#{base}#{url}"} );
      </script>
    EOF
  end


  CLASSES = {
    :dot =>{ :unavailable_variables => { :type => 'dot' } },
    :solid_dot =>{ :unavailable_variables => { :type => 'solid-dot' } },
    :hollow_dot =>{ :unavailable_variables => { :type => 'hollow-dot' } },
    :star =>{ :unavailable_variables => { :type => 'star' } },
    :bow => { :unavailable_variables => { :type => 'bow' } },
    :anchor => { :unavailable_variables => { :type => 'anchor' } },
    :title => { :available_variables => { :text => '', :style => "{font-size: 20px; color: #FF0F0F; text-align: center;}" } },
    :line_style => { :available_variables => { :style => 'dash', :on => '', :off => '' } },
    :line => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00' },
      :unavailable_variables => { :type => "line" }
    },
    :area => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :fill => '#0000FF', :fill_alpha => 0.6, :loop => false},
      :unavailable_variables => { :type => "area" }
    },
    :bar_stack_value => { :available_variables => { :value => 0, :colour => '#FF0000'} },
    :bar_stack_key => { :available_variables => { :text => '', :colour => '#FF0000', :font_size => 12 } },
    :bar_stack => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_stack" }
    },
    :h_bar_value => { :available_variables => { :left => 0, :right => nil} },
    :h_bar => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00'},
      :unavailable_variables => { :type => "hbar" }
    },
    :bar_value => { :available_variables => { :top => 0, :bottom => nil, :colour => '#FF0000', :tip => '#val#' } },
    :bar => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar" },
    },
    :bar_cylinder_outline => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_cylinder_outline" },
    },
    :bar_cylinder => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_cylinder" },
    },
    :bar_filled => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :outline_colour => '#00FF00', :alpha => 0.6},
      :unavailable_variables => { :type => "bar_filled" },
    },
    :bar_sketch => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :outline_colour => '#00FF00', :alpha => 0.6, :offset => 4 },
      :unavailable_variables => { :type => "bar_sketch" },
    },
    :bar_glass => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_glass" },
    },
    :bar_round_glass => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_round_glass" },
    },
    :bar_round => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_round" },
    },
    :bar_dome => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_dome" },
    },
    :bar3d => {
      :available_variables => { :text => 'label text', :font_size => 10, :colour => '#00FF00', :alpha => 0.6 },
      :unavailable_variables => { :type => "bar_3d" },
    },
    :pie_value => { },
    :pie_fade => { :unavailable_variables => { :type => "fade" } },
    :pie_bounce => {
      :available_variables => { :distance => 5},
      :unavailable_variables => { :type => "bounce" },
    },
    :pie => {
      :available_variables => { :colours => [], :alpha => 0.6, :start_angle => 35, :tip => '#val#', :gradient_fill => false, :label_colour => '#0000FF', :no_labels => false, :on_click => '', :shadow => false},
      :unavailable_variables => { :type => "pie" },
    },
    :y_axis => { },
    :y_axis_right => { },
    :y_legend => { :available_variables => { :text => "y legend", :style =>"{font-size: 20px; color:#0000ff; font-family: Verdana; text-align: center;}" } },
    :x_axis_label => { },
    :x_axis_labels => { },
    :x_axis => { },
    :x_legend => { :available_variables => { :text => "y legend", :style =>"{font-size: 20px; color:#0000ff; font-family: Verdana; text-align: center;}" } },
    :tooltip => { },
    :ofc_menu_item => {
      :available_variables => { :text => '', :javascript_function => '' },
      :unavailable_variables => { :type => 'text' },
    },
    :ofc_menu_item_camera => {
      :available_variables => { :text => '', :javascript_function => '' },
      :unavailable_variables => { :type => 'camera-icon' },
    },
    :ofc_menu => {
      :available_variables => { :colour => '', :outline__colour => '' },
      :unavailable_variables => { :type => 'camera-icon' },
    },
    :scatter_value => { :available_variables => { :x => 0, :y => 0} },
    :scatter => {
      :available_variables => { :text => 'label', :colour => '#FF0000' },
      :unavailable_variables => { :type => 'scatter' },
    },
    :scatter_line => {
      :available_variables => { :text => 'label', :colour => '#FF0000', :stepgraph => 'horizontal'},
      :unavailable_variables => { :type => 'scatter_line' },
    },
    :shape_point => { :available_variables => { :x => 0, :y => 0} },
    :shape => {
      :available_variables => { :colour => '#FF0000'},
      :unavailable_variables => { :type => 'shape' },
    },
    :radar_axis_labels => { :available_variables => { :labels => [], :colour => '#FAFFAF'} },
    :radar_spoke_labels => { :available_variables => { :labels => [], :colour => '#FAFFAF'} },
    :radar_axis => { }
  }

  CLASSES.each_key do |class_name|
    _class_name =class_name.to_s.camelize
    new_class = Class.new do
      include OWJSON

      def initialize( opts = {})
        class_data = CLASSES[self.class.name.demodulize.underscore.to_sym]

        class_data[:available_variables].each do |name, value|
          self.instance_variable_set("@#{name.to_s.gsub('_','__')}", value)
        end if class_data[:available_variables]

        opts.each do |name, value|
          self.instance_variable_set("@#{name.to_s.gsub('_','__')}", value)
        end

        class_data[:unavailable_variables].each do |name, value|
          self.instance_variable_set("@#{name.to_s.gsub('_','__')}", value)
        end if class_data[:unavailable_variables]
      end
    end

    const_set(_class_name, new_class)
  end



  #  +title+
  #  +x_axis+
  #  +y_axis+
  #  +y_axis_right+
  #  +x_legend+
  #  +y_legend+
  #  +bg_colour+
  #  +elements+
  class Graph
    include OWJSON

    # it must be done in that way because method_missing method replace _ to __,
    # maybe I add seccond parameter to handle with that
    %w(radar_axis x_axis y_axis y_axis_right x_legend y_legend bg_colour).each do |method|
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}") do
        self.instance_variable_get("@#{method}")
      end
    end

    def initialize
      @title = Title.new( "Graph" )
      @elements = []
    end

    def add_element( e )
      @elements << e
    end
    alias_method :<<, :add_element

    def render
      s = to_json
      # about underscores
      s.gsub!('___','') # that is for @___3d variable
      s.gsub!('__','-') # that is for @smt__smt variables
      # variables @smt_smt should go without changes
      s
    end
  end
end
