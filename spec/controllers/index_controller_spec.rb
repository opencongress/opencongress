require 'spec_helper'

describe IndexController do
  render_views
  describe 'index' do
    it 'should load' do
      get :index
      response.should be_success
    end

    it 'should load' do
      Article.should_receive(:frontpage_gossip).and_return([
        Article.new(
          :title => 'Title',
          :created_at => Time.now,
          :excerpt => 'blah, blah..'
        )
      ])
      get :index
      response.should have_selector("strong.gossip") do |content|
        content.text.should include('Title')
      end
    end
  end
end
