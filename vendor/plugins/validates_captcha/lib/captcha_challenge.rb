require 'digest/sha1'

module FleskPlugins #:nodoc:


  # This is an abstract class. Use one of its subclasses.
  class CaptchaChallenge

    include CaptchaConfig
    extend CaptchaConfig

    DEFAULT_TTL = 1200#Lifetime in seconds. Default is 20 minutes.

    attr_reader :id, :created_at
    attr_accessor :ttl
    
    @@types = HashWithIndifferentAccess.new



    def initialize(options = {}) #:nodoc:
      generate_id

      options = {
        :ttl => config['default_ttl'] || DEFAULT_TTL
      }.update(options)

      self.ttl = options[:ttl]
      @created_at = Time.now

      self.class.prune
    end


    # Implement in subclasses.
    def correct? #:nodoc:
      raise NotImplementedError
    end
    
    
    # Has this challenge expired?
    def expired?
      Time.now > self.created_at+self.ttl
    end
    
    
    def ==(other) #:nodoc:
      other.is_a?(self.class) && other.id == self.id
    end



  private

    def generate_id #:nodoc:
      self.id = Digest::SHA1.hexdigest(Time.now.to_s+rand.to_s)
    end


    def id=(i) #:nodoc:
      @id = i
    end


    def write_to_store #:nodoc:
      store.transaction{
        store[:captchas] = Array.new unless store.root?(:captchas)
        store[:captchas] << self
      }
    end



    class << self
    
      #Get the challenge type (class) registered with +name+
      def get(name)
        @@types[name]
      end
      
      #Register a challenge type (class) with +name+
      def register_name(name, klass = self)
        @@types[name] = klass
      end
    
      # Find a challenge from the storage based on its ID.
      def find(id)
        captcha = nil
        CaptchaConfig.store.transaction{|s|
          captcha = s[:captchas] && s[:captchas].find{|c| c.id == id }
        }
        captcha
      end
      
      # Delete a challenge from the storage based on its ID.
      def delete(id)
        captcha = nil
        CaptchaConfig.store.transaction{|s|
          captcha = s[:captchas] && s[:captchas].find{|c| c.id == id }
          s[:captchas] && s[:captchas].delete(captcha)
        }
      end
    
      # Removes old instances from PStore
      def prune
        store.transaction{
          if store.root?(:captchas)
            store[:captchas].each_with_index{|c,i|
              if c.expired?
                store[:captchas].delete_at(i)
              end
            }
          end
        }
      end#prune
  
    end#class << self


  end


end#module FleskPlugins
