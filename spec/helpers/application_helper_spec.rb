require 'spec_helper'

describe ApplicationHelper do
  describe 'position_clause' do
    it "expands the position string" do
      helper.position_clause('support').should == 'in support of'
      helper.position_clause('oppose').should == 'in opposition to'
    end

    it 'defaults to tracking' do
      helper.position_clause('').should == 'tracking'
    end
  end

end
