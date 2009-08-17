require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Agent::Worker do 
  
  before(:each) do
    @worker = Exceptional::Agent::Worker.new
  end
  
  describe "after initialisation" do
    
    it "should default worker timeout" do
      @worker.timeout.should == 10
    end
  
    it "should have no exceptions" do
      @worker.exceptions.should == []
    end
    
  end
  
end
