class RemoteForgeryProtectionGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      generate_javascript_file
    end
  end
  
  def generate_javascript_file
    path = RemoteForgeryProtection::JS_FILE_PATH
    File.open("#{RAILS_ROOT}/#{path}", "w") do |f|
      f.write "// This file will be automatically included if you put remote_forgery_protection helper inside head tag.\n\n"
      f.write RemoteForgeryProtection.javascript_code.strip
    end
    puts "\t* File '#{path}' generated."    
  end
  
end
