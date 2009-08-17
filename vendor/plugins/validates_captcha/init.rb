require 'captcha_config'
require 'captcha_challenge'
require 'captcha_question_challenge'
require 'add_captcha_to_active_record'
require 'add_captcha_to_action_view'
require 'add_captcha_to_action_controller'

#Don't load RMagick if it's not needed
unless FleskPlugins::CaptchaConfig.config['disable_image_challenges']
  begin
    require 'RMagick'
  rescue NameError
    puts "\nERROR: RMagick not available, ignoring"  
  rescue LoadError
    puts "\nERROR: Could not load RMagick. CAPTCHA image challenge not available. (validates_captcha)\n\n"
    RAILS_DEFAULT_LOGGER.error "\n\nERROR: Could not load RMagick. CAPTCHA image challenge not available. (validates_captcha)\n\n"
  else
    require 'captcha_image_challenge'
  end
else
  puts "** INFO: CAPTCHA image challenges are disabled. RMagick will not be loaded. (validates_captcha)"
  RAILS_DEFAULT_LOGGER.info "\n\nCAPTCHA image challenges are disabled. RMagick will not be loaded. (validates_captcha)\n\n"
end

ActiveRecord::Base.send(:include, FleskPlugins::Captcha::Validations)
ActionView::Base.send(:include, FleskPlugins::Captcha::Helpers)
ActionView::Helpers::FormBuilder.send(:include, FleskPlugins::Captcha::FormBuilderExtensions)
ActionController::Base.send(:include, FleskPlugins::Captcha::Verifications)