if defined? ActionController

module ActionController
  class Base
    def rescue_action_with_exceptional(exception)
      
      params_to_send = (respond_to? :filter_parameters) ? filter_parameters(params) : params
      
      Exceptional.handle(exception, self, request, params_to_send)
            
      rescue_action_without_exceptional exception
    end
    
    alias_method :rescue_action_without_exceptional, :rescue_action
    alias_method :rescue_action, :rescue_action_with_exceptional
    protected :rescue_action
  end
end

end