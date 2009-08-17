module FleskPlugins
  module Captcha
    module Verifications
    
      
      def self.included(base)#:nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
      end
  
  
      module ClassMethods#:nodoc:
      
      
        def verify_captcha_for(*args)#:nodoc:
          raise NotImplementedError
          options = args.last.is_a?(Hash) ? args.pop : {}
          options = {
            
          }.merge(options)
          
          before_filter :verify_captcha, :only => args
        end
      
      
      end#module ClassMethods


      #These methods are available in your
      #controller methods (actions).
      module InstanceMethods
      
        private
        
        # Verify a CAPTCHA challenge. You must
        # supply the ID and the user-contributed
        # validation (from params). It returns
        # false when the validation fails, and nil
        # when the challenge can't be found. Both
        # nil and false are false in a Boolean context,
        # so you only have to care about that if you want
        # to differentiate between the two.
        # 
        # This method is meant as an alternative to the
        # ActiveRecord extension +validates_captcha+, thus
        # keeping your model happily ignorant of the CAPTCHA
        # logic which really belongs in the controller.
        def captcha_valid?(captcha_id, captcha_validation) #:doc:
          captcha = CaptchaChallenge.find(captcha_id)
          if captcha
            if captcha.correct?(captcha_validation)
              true
            else
              false
            end
          else
            nil
          end
        end
      
      end
  
  
    end#module Verifications
  end#module Captcha
end#module FleskPlugins