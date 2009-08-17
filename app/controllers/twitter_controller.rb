class TwitterController < ApplicationController

#  require 'oauth'
  require 'twitter_oauth'

  before_filter :login_required, :except => :index
  
  def callback
    
    client = TwitterOAuth::Client.new(
        :consumer_key => '',
        :consumer_secret => ''
    )
    
    access_token = client.authorize(
      session[:twitter_token],
      session[:twitter_secret]
    )
    
    if client.authorized?
       u = User.find_by_id(current_user.id)
       twitter_config = u.twitter_config
       if u.twitter_config
         u.twitter_config.update_attributes({:secret => access_token.secret, :token => access_token.token})
         redirect_to edit_twitter_config_path(u.login, twitter_config) and return
       else
         twitter_config = TwitterConfig.create({:secret => access_token.secret, :token => access_token.token, :user_id => u.id})
         redirect_to edit_twitter_config_path(u.login, twitter_config) and return
       end
    else
       render :text => "There was a problem."
    end
    return
  end

  def index
    
  end

  def connect
    
    client = TwitterOAuth::Client.new(
      :consumer_key => '',
      :consumer_secret => ''
    )
    request_token = client.request_token
        
    redirect_to request_token.authorize_url
    
    session[:twitter_token] = request_token.token
    session[:twitter_secret] = request_token.secret
  
  end
  

end
