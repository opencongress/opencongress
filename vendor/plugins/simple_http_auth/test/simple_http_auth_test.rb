require 'rubygems'
require_gem 'rails'
require 'action_controller/test_process'
require 'test/unit'
require 'init'

ActionController::Base.template_root = 'test/fixtures'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

# The base class for testing.
class MockController < ActionController::Base
  def rescue_action(e) raise e end; 
  
  def index
    render :text => "Welcome to WonderPuppy's Happy Magic Pony Palace!"
  end
  
  def secret_ferret_brigade
    render :text => "Congratulations! You're obviously a member of the Secret Ferret Brigade!"
  end
  
  def logout    
    render :text => 'Really, no reason why you should see this.'
  end
end

# This should accept all requests.
class OpenUselessController < MockController
  requires_authentication :using => lambda{ |u, p| true }
end

# This should block all requests.
class ClosedUselessController < MockController
  requires_authentication :using => lambda{ |u, p| false }
end

# Authenticates only for the Secret Ferret Brigade(tm).
class AuthOnlyController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'ferret' && p == 'REVOLUTION' },
                          :only => [:secret_ferret_brigade]
end

# Authenticates only for the Secret Ferret Brigade(tm), but the other way around.
class AuthExceptController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'ferret' && p == 'REVOLUTION' },
                          :except => [:index]
end

# This shouldn't actually protect anything -- :except takes priority.
class ContradictoryController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'ferret' && p == 'REVOLUTION' },
                          :only => [:index],
                          :except => [:index]
end

# This should just protect :secret_ferret_brigade
class OverlySpecificController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'ferret' && p == 'REVOLUTION' },
                          :only => [:secret_ferret_brigade],
                          :except => [:index]
end

# Uses a controller method instead of a Proc.
class PrivateMethodController < MockController
  requires_authentication :using => :authenticate
private
  def authenticate(username, password)  
    username == 'ferret' && password == 'REVOLUTION'
  end
end

# Specifies a realm
class RealmController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'ferret' && p == 'REVOLUTION' },
                          :realm => "GOURANGA!"
end

# Uses a different list of possible headers.
class DifferentHeaderController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'ferret' && p == 'REVOLUTION' },
                          :at => ['MY_OWN_MAGIC1', 'MY_OWN_MAGIC2']
end

# Allows the user to log out.
class LogoutController < MockController
  requires_authentication :using => lambda{ |u, p| u == 'u' && p == 'p' },
                          :logout_on => :logout
end

class SimpleHttpAuthTest < Test::Unit::TestCase

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # There's enough jiggery-pokery with the Rails internals here that I want to 
  # make sure this won't eat some kind of horrible, orphan-killing,
  # false-negative-generating flaming death while my back's turned. Call me
  # paranoid; I dare you.
  def test_make_sure_the_testing_structure_works
    make_controller :mock
    get :index
    assert_response :success
    get :secret_ferret_brigade
    assert_response :success
  end
  
  # Make sure we're accepted or bounced at all.
  def test_useless_configurations
    make_controller :open_useless
    get :index
    assert_response :success
    get :secret_ferret_brigade
    assert_response :success

    make_controller :closed_useless
    get :index
    assert_protected
    get :secret_ferret_brigade
    assert_protected
  end
  
  # Make sure we limit ourselves properly.
  def test_auth_only
    make_controller :auth_only
    get :index
    assert_response :success
    get :secret_ferret_brigade
    assert_protected
  end
  
  # Make sure we can log in.
  def test_auth_only_actually_logging_in
    test_auth_only
    login :secret_ferret_brigade, 'ferret', 'REVOLUTION'
    assert_response :success
    login :secret_ferret_brigade, 'ferret', 'WRONGPASSWORD'
    assert_protected
  end
  
  # Make sure we don't box ourselve in, eh?
  def test_contradictory
    make_controller :contradictory
    get :index
    assert_response :success
    get :secret_ferret_brigade
    assert_response :success
  end
  
  # Erring on the Side of Verbosity should Never incur Penalties beyond, perhaps,
  # the Animonsity and Misapprehension of the Hoi Polloi, though said Slings and
  # Arrows are themselves, as the Bard had it, Outrageous in their Illogical and
  # Arbitrary Application by either Providence or Fortune, the Difference
  # between which is Said to comprise the Greater Portion of Wisdom, and Should,
  # at All Costs, be Avoided in Part and in Whole.
  def test_overly_specific
    make_controller :overly_specific
    get :index
    assert_response :success
    get :secret_ferret_brigade
    assert_protected
  end
  
  # Make sure we limit ourselves properly.
  def test_auth_except
    make_controller :auth_except
    get :index
    assert_response :success
    get :secret_ferret_brigade
    assert_protected
  end
  
  # Make sure we can log in.
  def test_auth_except_actually_logging_in
    test_auth_except
    login :secret_ferret_brigade, 'ferret', 'REVOLUTION'
    assert_response :success
    
    login :secret_ferret_brigade, 'ferret', 'WRONGPASSWORD!'
    assert_protected
  end
  
  # Make sure we can use a controller method.
  def test_private_method
    make_controller :private_method
    get :index
    assert_protected
    get :secret_ferret_brigade
    assert_protected
  end
  
  # Make sure we can log in.
  def test_private_method_actually_logging_in
    test_private_method
    login :index, 'ferret', 'REVOLUTION'
    assert_response :success
    login :index, 'ferret', 'WRONGPASSWORD'
    assert_protected
  end
  
  # Make sure our realm shows up.
  def test_realm
    make_controller :realm
    get :index
    assert_protected
    assert_equal 'Basic realm="GOURANGA!"', @response.headers['WWW-Authenticate']
  end
  
  # Make sure we can specify different headers.
  def test_different_method
    make_controller :different_header
    get :index
    assert_protected
    login :index, 'ferret', 'REVOLUTION', 'MY_OWN_MAGIC1'
    assert_response :success
    login :index, 'ferret', 'REVOLUTION', 'MY_OWN_MAGIC2'
    assert_response :success
  end
  
  # Make sure that logging us out actually does so.
  def test_logging_out
    make_controller :logout
    login :index, 'u', 'p'
    assert_response :success
    login :index, 'u', 'ping'
    assert_protected
    login :logout, 'u', 'p'
    assert_protected 'You have successfully logged out.'
  end
  
  # Make sure Julien's bug is fixed
  def test_multiline_credentials
    make_controller :auth_only    
    
    @request.env['HTTP_AUTHORIZATION'] = "Basic MjoT2yEbWGt02kaRJW7KZPCbZBQBPuQGaajMpUKN3npIlsWTgbs89Nkjk5iZ\nAvrsMVbgYeahS4ljXySP04sF8xf9\n"
    get :index
    
    SimpleHTTPAuthentication::ActionFilter.instance_eval do
      public :get_auth_data
    end
    
    begin
      af = SimpleHTTPAuthentication::ActionFilter.new({})
      username, password = af.get_auth_data(@controller)
    ensure
     SimpleHTTPAuthentication::ActionFilter.instance_eval do
        private :get_auth_data
      end
    end
   
    assert_equal 64, password.size
  end
  
  
private

  # Since we're testing different controllers, here's a little sump'en-sump'en
  # to make my life easier. Also? It looks cooler.
  def make_controller(klass)
    @controller = eval("#{klass.to_s.camelize}Controller").new
  end
  
  # Logs in to an action using the specified username and password.
  def login(action, username, password, header = 'HTTP_AUTHORIZATION')
    @request.env[header] = "Basic #{Base64.encode64(username << ':' << password)}"
    get action
  end
  
  # Short-hand for "no, you can't play with us"
  def assert_protected(msg = "401 Unauthorized: You are not authorized to view this page.")
    assert_response 401
    assert_equal msg, @response.body
  end

end
