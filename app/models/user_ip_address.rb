class UserIpAddress < ActiveRecord::Base

  belongs_to :user

  require 'ipaddr'

  def self.find_by_ip(address)
     ip = UserIpAddress.int_form(address)
     self.find_by_addr(ip, :order => "created_at DESC")
  end

  def self.find_all_by_ip(address)
     ip = UserIpAddress.int_form(address)
     self.find_all_by_addr(ip, :order => "created_at DESC")
  end

  def self.int_form(address)
    IPAddr.new(address).to_i
  end
  
  def to_s
    IPAddr.new(self.addr, Socket::AF_INET).to_s
  end

end
