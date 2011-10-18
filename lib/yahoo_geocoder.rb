class YahooGeocoder
  
  attr_accessor :address
  attr_accessor :zip5
  attr_accessor :zip4
  attr_accessor :city
  
  def initialize(this_address)
    @address = this_address
    @key = ApiKeys.yahoo_apis
    @zip5 = ''
    @zip4 = ''
    self.geocode
  end
  
  def geocode
    require 'hpricot'
    require 'open-uri'
    begin
      doc = Hpricot.XML(open("http://where.yahooapis.com/geocode?q=#{CGI::escape(@address)}&appid=#{@key}"))


      #puts "\n\n\nHERE's the DOC: #{doc}\n\n\n"
      if doc
        zip = (doc/:Result/:postal).inner_html
        @zip5,@zip4 = zip.split('-')
        @city = (doc/:Result/:city).inner_html
        return true
      else
        return false
      end
    rescue
      logger.warn "Error with Yahoo API: #{$!}"
      return false
    end
  end

  
end