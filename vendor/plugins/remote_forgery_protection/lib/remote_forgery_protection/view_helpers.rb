module RemoteForgeryProtection  
  module ViewHelpers    
    
    def remote_forgery_protection(options = {})
      if options[:preincluded]
        token_script_tag
      elsif !options[:inline] and File.exist?("#{RAILS_ROOT}/#{RemoteForgeryProtection::JS_FILE_PATH}")
        %{
          #{token_script_tag}
          #{javascript_include_tag(RemoteForgeryProtection::JS_FILE_NAME)}
        }
      else
        javascript_tag %{
          #{token_declaration}
          #{RemoteForgeryProtection.javascript_code}
        }
      end
    end 
    
    def token_declaration
      "window._token = '#{form_authenticity_token}';"
    end
    
    def token_script_tag
      javascript_tag token_declaration
    end
    
  end  
end