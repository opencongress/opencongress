require 'exceptional'

def to_stderr(s)
  STDERR.puts "** [Exceptional] " + s
end

config_file = File.join(RAILS_ROOT,"/config/exceptional.yml")

begin 
  Exceptional.application_root = RAILS_ROOT
  Exceptional.environment = RAILS_ENV
  
  Exceptional.load_config(config_file)
  if Exceptional.enabled?
    Exceptional::Rails.init
  end
rescue Exception => e
  to_stderr e
  to_stderr "Plugin disabled."
end
