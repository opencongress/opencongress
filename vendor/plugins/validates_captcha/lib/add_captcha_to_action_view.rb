require 'action_view'

module FleskPlugins #:nodoc:
  module Captcha #:nodoc:


    # Captcha helper methods. See README for an introduction.
    module Helpers
    
      #Synchronise with FormBuilderExtensions!


      # Prepares a CAPTCHA challenge for use in a form. This method must
      # be called before using any of the other helper methods,
      # as it returns the object these methods need to work.
      # 
      # Use like this (in your view):
      # 
      # <% c = generate_captcha() -%>
      # 
      # You can supply an optional hash
      # which can contain the following options:
      # 
      # - :type - The type of challenge. This can be
      #   either +:image+ or +question+. If not specified,
      #   +:image+ will be assumed.
      #   
      # All the options are passed on to the challenge
      # constructor methods. Look in CaptchaImageChallenge#initialize
      # and CaptchaQuestionChallenge#initialize to see what options
      # each type takes.
      def prepare_captcha(options = {})
        #Default to :image for backwards compability
        CaptchaChallenge.get(options.delete(:type) || :image).new(options)
      end


      # Returns an +image+ tag with the image generated in the
      # +challenge+ object.
      # 
      # The +options+ parameter is passed on to both CaptchaImageChallenge#generate
      # and Rails' image_tag method, so you can control how the image
      # and tag are generated.
      def captcha_image_tag(challenge, options = {})
        challenge.generate(options)
        challenge.write
        [:fontsize, :padding, :color, :background, :fontweight, :rotate, :font].each{|k| options.delete(k) }

        image_tag(
          challenge.file_path,
          {
            :size => "#{challenge.image.columns}x#{challenge.image.rows}",
            :alt => 'CAPTCHA image'
          }.merge(options)
        )
      end
      
      
      #Returns the question for a CaptchaQuestionChallenge
      def captcha_question(challenge, options = {})
        challenge.question
      end
      
      
      #Returns a label tag for the input field containing
      #the question from a CaptchaQuestionChallenge.
      def captcha_question_as_label(challenge, object, options = {})
        options = {
          :for => "#{object}_captcha_validation"
        }.update(options)
        
        content_tag('label', "#{options[:before]}#{challenge.question}#{options[:after]}", options)
      end


      # Creates a hidden input field called <tt>object[captcha_id]</tt>,
      # with +challenge+'s id as value. The +options+ hash is
      # passed on to the +hidden_field+ helper.
      # 
      # This field must be present for the form to validate.
      def captcha_hidden_field(challenge, object, options = {})
        options = {
          :value => challenge.id
        }.merge(options)
        
        hidden_field(object, 'captcha_id', options)
      end


      # Creates a text field for the user to type
      # the solution to the challenge (i.e. the
      # text from the image or the answer to the
      # question) into.
      # 
      # The +options+ hash is passed on to the
      # +text_field+ helper.
      # 
      # Must be present for form/model object to validate.
      def captcha_text_field(object, options = {})
        text_field(object, 'captcha_validation', options)
      end


      # Creates a +label+ tag with the +for+ attribute
      # set to +object_captcha_validation+.
      # 
      # The +options+ hash is passed on to the
      # +content_tag+ helper.
      def captcha_label(object, name = 'CAPTCHA validation', options = {})
        options = {
          :for => "#{object}_captcha_validation"
        }.merge(options)
        
        content_tag('label', name, options)
      end


      def captcha_ttl(c) #:nodoc:
        c.ttl
      end


    end#module Helpers


    #For use with +form_for+ and +fields_for+.
    module FormBuilderExtensions
    
      #Synchronise with Helpers module
      
      StupidError = Class.new(StandardError)
    
    
      def captcha_text_field(options = {})
        text_field('captcha_validation', options)
      end
      
      
      def captcha_hidden_field(challenge, options = {})
        options = {
          :value => challenge.id
        }.merge(options)
        
        hidden_field('captcha_id', options)
      end
      
      
      def captcha_label(name = 'CAPTCHA validation', options = {})
        options = {
          :for => "#{object_name}_captcha_validation"
        }.merge(options)
        
        @template.send(:content_tag, 'label', name, options)
      rescue
        raise StupidError, "Oops, I relied on some Rails internals, and now they've changed it apparently. Please let me know about it."
      end
      
      
      def captcha_question_as_label(challenge, options = {})
        options = {
          :for => "#{object_name}_captcha_validation"
        }.update(options)
        
        @template.send(:content_tag, 'label', "#{options[:before]}#{challenge.question}#{options[:after]}", options)
      rescue
        raise StupidError, "Oops, I relied on some Rails internals, and now they've changed it apparently. Please let me know about it."
      end
    
    
    end#module FormBuilderExtensions


  end#module Captcha
end#module FleskPlugins
