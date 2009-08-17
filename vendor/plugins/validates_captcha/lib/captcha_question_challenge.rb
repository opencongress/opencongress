module FleskPlugins


  #This CAPTCHA challenge asks the user a simple question
  #which a machine probably will not understand. This
  #type of challenge is much more accessible than the
  #typical image challenge.
  class CaptchaQuestionChallenge < CaptchaChallenge
  
    register_name :question
  
    attr_accessor :question, :answer
  
  
    # Creates a question challenge, in which the user must
    # answer a (simple) question to prove he is not a machine.
    # 
    # Options:
    # 
    # - :ttl - The challenge's lifetime in seconds. After this
    #   period it will be deleted. Default is 1200 (20 minutes).
    # - :question - The question to use for this challenge.
    # - :answer - The answer to use for this challenge.
    def initialize(options = {})
      super
      
      if config['questions'].is_a?(Enumerable) && !options.include?(:question)
        options[:question], options[:answer] = config['questions'][rand(config['questions'].size)]
      end
      
      options.reverse_merge!(
        :question => 'What is 2+2?',
        :answer => ['4', 'four']
      )
      
      self.question = options[:question]
      self.answer = options[:answer]
      
      write_to_store
    end
    
    
    # Determine if an answer given by the user is correct.
    def correct?(answer)
      if self.answer.is_a? Regexp
        self.answer =~ answer
      elsif self.answer.is_a? Enumerable#list of Strings and/or Regexps
        self.answer.any?{|a|
          if a.is_a? Regexp
            answer =~ a
          else
            answer.to_s.downcase.include?(a.to_s.downcase)
          end
        }
      else#String
        answer.to_s.downcase.include?(self.answer.to_s.downcase)
      end
    end
  
  
  end#class CaptchaQuestionChallenge


end#module FleskPlugins