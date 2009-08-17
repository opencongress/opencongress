class FixCommentaryEncoding < ActiveRecord::Migration
require 'htmlentities'
  def self.up
    ent = HTMLEntities.new
    comm = Commentary.find(:all, :conditions => [ "commentaries.date > ?", 120.days.ago])
    comm.each do |c|
      c.title = ent.encode(c.title.unpack("U*").pack("C*")).unpack('U*').pack('U*')
      c.excerpt = ent.encode(c.excerpt.unpack("U*").pack("C*")).unpack('U*').pack('U*')
      c.save
    end  
  end

  def self.down
    ent = HTMLEntities.new
    comm = Commentary.find(:all, :conditions => [ "commentaries.date > ?", 120.days.ago])
    comm.each do |c|
      c.title = ent.decode(c.title.unpack("U*").pack("U*")).unpack("C*").pack("U*")
      c.excerpt = ent.decode(c.excerpt.unpack("U*").pack("U*")).unpack("C*").pack("U*")
      c.save
    end
  end
end
