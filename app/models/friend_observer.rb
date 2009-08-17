class FriendObserver < ActiveRecord::Observer

  def after_create(friend)
    UserNotifier.deliver_friend_notification(friend) unless friend.confirmed == true
  end

  def before_destroy(friend)
   unless @reciprical_flag
    UserNotifier.deliver_friend_rejected_notification(friend) if friend.confirmed == false 
    UserNotifier.deliver_friendship_broken_notification(friend) if friend.confirmed == true 
    reciprical = Friend.find_by_friend_id_and_user_id(friend.user_id, friend.friend_id)
    UserNotifier.deliver_friendship_broken_notification(reciprical) if friend.confirmed == true
#    UserNotifier.deliver_friend_rejected_notification(reciprical) if friend.confirmed == false
    @reciprical_flag = true
    reciprical.destroy if reciprical
   end
  end

  def after_save(friend)
    if friend.recently_confirmed?
      UserNotifier.deliver_friend_confirmed_notification(friend) 
      Friend.create({:friend_id => friend.user_id, :user_id => friend.friend_id, :confirmed => true, :confirmed_at => Time.new}) unless Friend.find_by_friend_id_and_user_id(friend.user_id, friend.friend_id)
    end
  end
end

