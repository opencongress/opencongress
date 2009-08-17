module Exceptional
      
    class Rails
      
      def self.init
        Exceptional.deployed_environment = DeployedEnvironment.new
        # If no server environment detected, don't perform magic. 
        # Means rake, script/console etc perform as expected
        return false unless Exceptional.deployed_environment.should_start_worker?
        
        setup_log
        Exceptional.log_config_info
        
        if Exceptional.authenticate           
        
          if Exceptional.mode == :queue
            Exceptional.worker = Agent::Worker.new(Exceptional.log)
            Exceptional.worker_thread = Thread.new do
              Exceptional.worker.run
            end
          end
          
          require File.join(File.dirname(__FILE__), 'integration', 'rails')
          
          
          at_exit do
            if Exceptional.mode == :queue         
              Exceptional.worker_thread.terminate if Exceptional.worker_thread
            end
          end
        else
          Exceptional.log! "Plugin not authenticated, check your API Key"
          Exceptional.log! "Disabling Plugin."
        end
      end
      
      def self.setup_log
        log_file = "#{Exceptional.application_root}/log/exceptional.log"

        @log = Logger.new log_file
        @log.level = Logger::INFO

        allowed_log_levels = ['debug', 'info', 'warn', 'error', 'fatal']
        if Exceptional.log_level && allowed_log_levels.include?(Exceptional.log_level)
          @log.level = eval("Logger::#{Exceptional.log_level.upcase}")
        end

        Exceptional.log = @log
      end
      
    end
      
end
