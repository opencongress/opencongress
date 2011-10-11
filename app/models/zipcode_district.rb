class ZipcodeDistrict < ActiveRecord::Base 
  def ZipcodeDistrict.zip_lookup(zip5, zip4 = nil)
    if zip4.blank?
      self.select("DISTINCT state, district").where(["zip5 = ?", zip5]).all
    else
      self.select("DISTINCT state, district").where(["zip5 = ? AND (zip4 = ? OR zip4 = 'xxxx')", zip5, zip4]).all
    end
  end
  
  def self.from_address(address)
    require 'yahoo_geocoder'
    y = YahooGeocoder.new(address)
    if y
      zip4 = y.zip4
      zip5 = y.zip5
      unless zip5.blank?
        return ZipcodeDistrict.zip_lookup(zip5, zip4)
      else
        return nil
      end
    end
  end
  
end