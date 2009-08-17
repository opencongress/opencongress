class CaptchaGenerator < Rails::Generator::NamedBase

  include FleskPlugins::CaptchaConfig


  def manifest
    record {|m|
      case file_name
        when 'config'
          m.file 'captcha.yml', File.join('config', 'captcha.yml')

        when 'image_directory'
          m.directory File.join('public', 'images', config['default_dir'] || 'captcha')

        when 'store_directory'
          m.directory File.join('var', 'data')

        else
          puts "Could not recognise action \"#{file_name}\"."

      end
    }
  end


  def banner
    "Usage: #{$0} #{spec.name} <action>"
  end


end
