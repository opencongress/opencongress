require 'active_support'
require 'base64'

module SimpleHTTPAuthentication #:nodoc:

  def self.append_features(base) #:nodoc:
    super
    base.extend(ClassMethods)
  end

  # A simple module for providing a humane interface for Basic HTTP
  # Authentication, as described in RFC 2617.
  module ClassMethods #:doc:
    # Enables HTTP authentication for a controller. See the README for a better
    # walk-through of how to use this method.
    def requires_authentication(options)
      if options[:using]
        around_filter(SimpleHTTPAuthentication::ActionFilter.new(options))
      else
        raise ArgumentError.new('must include :using, as a Proc or Symbol')
      end
    end
  end

  class ActionFilter #:nodoc:
    attr_accessor :only_actions, :except_actions, :event_handler,
                  :auth_location, :realm, :error_msg, :logout_action
  
    def initialize(options)
      @only_actions = options[:only] || []
      @except_actions = options[:except] || []
      @event_handler = options[:using] || lambda{ |username, password| true }
      @auth_locations = options[:at] || ['REDIRECT_REDIRECT_X_HTTP_AUTHORIZATION',
                                         'REDIRECT_X_HTTP_AUTHORIZATION',
                                         'X-HTTP_AUTHORIZATION', 'HTTP_AUTHORIZATION']
      @realm = options[:realm] || 'Login Required'
      @logout_action = options[:logout_on]
      @error_msg = options[:error_msg] || "401 Unauthorized: You are not authorized to view this page."
    end
  
    def before(controller)
      if controller.action_name.intern == @logout_action
        controller.response.headers["Status"] = "Unauthorized"
        controller.response.headers["WWW-Authenticate"] = "Basic realm=\"#{@realm}\""
        controller.render :action => @logout_action.to_s, :status => 401
        return false
      elsif (@only_actions.include?(controller.action_name.intern) || @only_actions.empty?) && !@except_actions.include?(controller.action_name.intern)
        username, password = get_auth_data(controller)
        authenticated = false
        if @event_handler
          if @event_handler.is_a?(Proc)
            authenticated = controller.instance_exec(username, password, &@event_handler)
          elsif @event_handler.is_a?(Symbol) || @event_handler.is_a?(String)
            simple_http_auth_handler = @event_handler
            controller.instance_eval do
              authenticated = self.send(simple_http_auth_handler, username, password)
            end
          else
            authenticated = true
          end
        else
          authenticated = true
        end
        
        unless authenticated
          controller.response.headers["Status"] = "Unauthorized"
          controller.response.headers["WWW-Authenticate"] = "Basic realm=\"#{@realm}\""
          controller.render :text => @error_msg, :status => 401
        end
        return authenticated
      end
    end
    
    def after(controller)
      # This needs to be here, or Rails complains.
    end
    
  private
  
    def get_auth_data(controller)
      authdata = nil
      for location in @auth_locations
        if controller.request.env.has_key?(location)
          # split based on whitespace, but only split into two pieces
          authdata = controller.request.env[location].to_s.split(nil, 2)
        end
      end
      if authdata and authdata[0] == 'Basic' 
        user, pass = Base64.decode64(authdata[1]).split(':')[0..1] 
      else
        user, pass = ['', '']
      end
      return user, pass
    end
  
  end
end

module ActionController #:nodoc:
  class Base #:nodoc:
    include SimpleHTTPAuthentication
  end
end
