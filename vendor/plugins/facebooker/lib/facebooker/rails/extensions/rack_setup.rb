require 'rack/facebook'
ActionController::Dispatcher.middleware.insert_after(
 (Object.const_get('ActionController::RewindableInput') rescue false) ? 'ActionController::RewindableInput' : 'ActionController::Session::CookieStore', Rack::Facebook, Facebooker.secret_key )
