module FriendsHelper
  
  def user_name(pronoun,extras)
		if @user == current_user
			use_name = "#{pronoun}"
		else
 			use_name = @user.login + "#{extras}"
		end
	end
end
