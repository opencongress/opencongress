require 'spec_helper'

describe IndexController do
  render_views
  describe 'index' do
    it 'should load' do
      get :index
      response.should be_success
    end
  end
end
