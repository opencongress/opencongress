class ApacheBan
  
  def initialize
  end
  
  def self.create_by_ip(ipaddr)
    gots = false
    file = File.open(Settings.ban_file, 'r+')
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
    file = File.open(Settings.ban_file)
    file_contents = file.read
    file.close

    new_contents = ""

    file_contents.each do |f|
      unless f =~ /#{ipaddr} b/
        new_contents << f
      end
    end
    file = File.open(Settings.ban_file, 'w')
    file.puts new_contents
    file.close
      
  end  
  
  
  
  
  
end