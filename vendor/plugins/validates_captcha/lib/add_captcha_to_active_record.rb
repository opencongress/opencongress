require 'active_record'

module FleskPlugins #:nodoc:
  module Captcha #:nodoc:


    #AR validations
    module Validations #:nodoc:


      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end


      # Class methods to be used in your models.
      module ClassMethods


        # Validates a CAPTCHA challenge.
        # 
        #   class MySuperModel
        #     validates_captcha :message => "Nope, that wasn't it at all."
        #   end
        # 
        # This method adds two accessors to your model, +captcha_id+ and +captcha_validation+, and
        # makes them accessible for mass-assignment. They are virtual, so you don't need them in
        # your database table. You will have to assign them values from your form in your controller, but
        # if you do something like <tt>tyra = MySuperModel.new(params[:my_super_model])</tt> and you use
        # the helpers in Helpers::Captcha, this will happen automatically. Note that if you use
        # <tt>attr_accessible</tt>, you will have to place the <tt>validates_captcha</tt>
        # after this to have the attributes automatically assigned.
        # 
        # It takes the optional <tt>:on</tt> and <tt>:if</tt> parameters, that work like in Rails'
        # built-in validations.
        # 
        #   class MySuperModel
        #     validates_captcha :on => :create, :if => Proc.new{|r| !r.has_user? }
        #   end
        def validates_captcha(options = {})
          options = {
            :message => CaptchaConfig.config['default_message'] || 'CAPTCHA validation did not match.'
          }.update(options)

          include FleskPlugins::Captcha::Validations::InstanceMethods

          class_eval {
            attr_accessor :captcha_id, :captcha_validation
            attr_accessible :captcha_id, :captcha_validation if accessible_attributes
            
            after_create :delete_captcha

            send(validation_method(options[:on] || :save)){|record|
              unless options[:if] && !evaluate_condition(options[:if], record)
                record.send(:validate_captcha, options)
              end
            }
          }
        end


      end#module ClassMethods


      # module InstanceMethods
      module InstanceMethods #:nodoc:


        def prepare_captcha #:nodoc:
          raise NotImplementedError
        end


      private

        def validate_captcha(options = {}) #:nodoc:
          #Don't add errors if in test mode. Makes
          #adding extra logic to unit tests unnecessary.
          unless RAILS_ENV == 'test' && !CaptchaConfig.config['i_will_test_validation_myself_thank_you_very_much']
            captcha = CaptchaChallenge.find(captcha_id)
  
            if captcha
              if !captcha.correct?(captcha_validation)
                errors.add('captcha_validation', options[:message])
              elsif captcha.expired?
                errors.add('captcha_validation', 'CAPTCHA expired.')
              end
            else
              logger.info captcha_id.inspect
              errors.add('captcha_validation', 'CAPTCHA not found.')
            end
          end
        end
        
        
        def delete_captcha
          CaptchaChallenge.delete(captcha_id)
        end


      end


    end#module Validations


  end#module Captcha
end#module FleskPlugins
