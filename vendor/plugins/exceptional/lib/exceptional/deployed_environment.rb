# This class is used to determine the server environment
module Exceptional
  class DeployedEnvironment
  
    attr_reader :server, :identifier, :hostname#, :environment
  
    def initialize
      @server = :unknown
      @identifier = nil
    
      @hostname = determine_host
      # @environment = Exceptional.environment
      # @application_root = Exceptional.application_root
    
      servers = %w[webrick mongrel thin litespeed passenger]
      while servers.any? && @identifier.nil?
        send 'is_'+(servers.shift)+'?'
      end
    
    end
  
    def should_start_worker?
      !identifier.nil?
    end
  
    def determine_mode
      @server == :passenger ? :direct : :queue      
    end
  
    def to_s
      "#{@hostname}:#{@identifier} [#{@server}]"
    end
  
    def determine_host
      Socket.gethostname
    end
  
    def is_webrick?
      if defined?(OPTIONS) && defined?(DEFAULT_PORT) && OPTIONS.respond_to?(:fetch) 
        # OPTIONS is set by script/server if launching webrick
        @identifier = OPTIONS.fetch :port, DEFAULT_PORT 
        @server = :webrick
      end
    end
  
    def is_mongrel?
      if defined? Mongrel::HttpServer
        ObjectSpace.each_object(Mongrel::HttpServer) do |mongrel|
          next unless mongrel.respond_to? :port
          @server = :mongrel
          @identifier = mongrel.port
        end
      end
    end
  
    def is_thin?
      if defined? Thin::Server
        ObjectSpace.each_object(Thin::Server) do |thin_server|
          @server = :thin
          backend = thin_server.backend
          if backend.respond_to? :port
            @identifier = backend.port
          elsif backend.respond_to? :socket
            @identifier = backend.socket
          end
        end
      end
    end
      
    def is_litespeed?
      if caller.pop =~ /fcgi-bin\/RailsRunner\.rb/
        @server = :litespeed
        @identifier = 'litespeed'
      end
    end
  
    def is_passenger?
      if defined? Passenger::AbstractServer
        @server = :passenger
        @identifier = 'passenger'
      end
    end
    
  end
end

