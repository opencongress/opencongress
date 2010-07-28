class YahooGeocoder
  
  attr_accessor :address
  attr_accessor :zip5
  attr_accessor :zip4
  
  def initialize(this_address)
    @address = this_address
    @key = API_KEYS['yahoo_apis']
    @zip5 = ''
    @zip4 = ''
    self.geocode
  end
  
  def geocode
    require 'hpricot'
    require 'open-uri'
    begin
      doc = Hpricot.XML(open("http://local.yahooapis.com/MapsService/V1/geocode?appid=#{@key}&location=#{CGI::escape(@address)}"))
      if doc
        zip = (doc/:Result/:Zip).inner_html
        @zip5,@zip4 = zip.split('-')
        return true
      else
        return false
      end
    rescue
      return false
    end
  end

  
end