module IGOpeople
  module Routing
    module BorkOnNamedRouteClash
      def self.included(base)
        base.alias_method_chain :add_named_route, :checking_clash
      end

      def add_named_route_with_checking_clash(name, path, options = {})
        if named_routes[name.to_sym].nil?
          add_named_route_without_checking_clash(name,path,options)
        else
          raise('clashing named route: '+ name.to_s)
        end
      end
    end
  end
end

if Rails.env.development? || Rails.env.test?
  ActionController::Routing::RouteSet.send(:include, 
      IGOpeople::Routing::BorkOnNamedRouteClash)
end
