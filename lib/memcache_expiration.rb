class MemcacheExpiration
  require 'rubygems'
  require 'memcache'
  require 'o_c_logger'

  @connection = nil
  @namespace = nil

  def initialize(namespace = "opencongress_#{Rails.env}")
    @namespace = namespace
    connect
  end

  def show_stats
    connect unless connection_active?
    
    return @connection.stats rescue nil
  end

  def show_one_frag(fragment)
    connect unless connection_active?

    return @connection.get("views/#{fragment}", true) rescue nil
  end

  def expire_frag(fragment)
    connect unless connection_active?
    
    begin
      if fragment.class.to_s == "Array"
        fragment.each do |f|
          f = "views/#{f}"
          @connection.delete(f)
        end
      else
        @connection.delete("views/#{fragment}")
      end
    rescue Exception => e
      OCLogger.log "WARNING: Error deleting cached fragment or array '#{fragment}': #{e}"
    end
  end

  def flush_all 
    connect unless @connection.active?
    
    return @connection.flush_all rescue nil
  end

  protected
  
  def connection_active?
    begin
      stats = @connection.stats
      return true if stats
    rescue
      return false
    end
  end

  def connect
    if Rails.env == 'production'
      hostport = '10.13.219.6:11211' 
      errorcount = 0
    
      while errorcount < 5
        begin
          @connection = MemCache.new(hostport, :namespace => @namespace)
          return if connection_active?
        rescue
          OCLogger.log "Error connecting to memcache server.  Trying again..."
          errorcount += 1
        end
      end
    
      raise "Could not connect to memcache server!!"
    end
  end
end
