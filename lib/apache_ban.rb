class ApacheBan
  
  def initialize
  end
  
  def self.create_by_ip(ipaddr)
    gots = false
    file = File.open(BAN_FILE, 'r+')
    file.each do |line|
      if line =~ /#{ipaddr}/
        gots = true
      end
    end
    

    if gots == false
      file.puts "#{ipaddr} b"
      file.close
    end
      
  end

  def self.delete_by_ip(ipaddr)
    file = File.open(BAN_FILE)
    file_contents = file.read
    file.close

    new_contents = ""

    file_contents.each do |f|
      unless f =~ /#{ipaddr} b/
        new_contents << f
      end
    end
    file = File.open(BAN_FILE, 'w')
    file.puts new_contents
    file.close
      
  end  
  
  
  
  
  
end