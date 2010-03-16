class Friend < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"

  def confirm
    @confirmed = true
    update_attributes!({:confirmed => true, :confirmed_at => Time.new})
  end

  def recently_confirmed?
    @confirmed
  end
  
  def self.recent_activity(friends)
    ra = []
    number_of_friends = friends.length
    range = [0..3]
    case number_of_friends
    when 1
      friends.each do |f|
        ra.concat(f.friend.recent_public_actions(12)[0..11])
      end
    when 2
      friends.each do |f|
        ra.concat(f.friend.recent_public_actions(6)[0..5])
      end
    else
      friends.each do |f|
        ra.concat(f.friend.recent_public_actions(4)[0..3])
      end
    end

    ra.compact.sort_by{|p| p.created_at}.reverse
  end

  def self.create_confirmed_friendship(u1, u2)
    Friend.create({:friend_id => u1.id, :user_id => u2.id, :confirmed => true, :confirmed_at => Time.new})
    Friend.create({:friend_id => u2.id, :user_id => u1.id, :confirmed => true, :confirmed_at => Time.new})
  end
end
