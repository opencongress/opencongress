require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true
  
  fixtures :users
  
  def setup

    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_auth_bob
    @request.session['return-to'] = "/bogus/location"

    post :login, "user_login" => "bob", "user_password" => "test"
    assert_session_has "user"

    assert_equal @bob, @response.session["user"]
    
    assert_redirected_to "/bogus/location"
  end
  
  def test_signup
    @request.session['return-to'] = "/bogus/location"

    post :signup, "user" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "newpassword" }
    assert_session_has "user"
    
    assert_redirected_to "/bogus/location"
  end

  def test_bad_signup
    @request.session['return-to'] = "/bogus/location"

    post :signup, "user" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "wrong" }
    assert_invalid_column_on_record "user", "password"
    assert_success
    
    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "newpassword" }
    assert_invalid_column_on_record "user", "login"
    assert_success

    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "wrong" }
    assert_invalid_column_on_record "user", ["login", "password"]
    assert_success
  end

  def test_invalid_login
    post :login, "user_login" => "bob", "user_password" => "not_correct"
     
    assert_session_has_no "user"
    
    assert_template_has "message"
    assert_template_has "login"
  end
  
  def test_login_logoff

    post :login, "user_login" => "bob", "user_password" => "test"
    assert_session_has "user"

    get :logout
    assert_session_has_no "user"

  end
  
end
