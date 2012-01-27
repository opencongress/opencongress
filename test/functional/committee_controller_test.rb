require File.dirname(__FILE__) + '/../test_helper'
require 'committee_controller'

# Raise errors beyond the default web-based presentation
class CommitteeController; def rescue_action(e) raise e end; end

class CommitteeControllerTest < Test::Unit::TestCase
  def setup
    @controller = CommitteeController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_index
    get :index
  end
  
end
