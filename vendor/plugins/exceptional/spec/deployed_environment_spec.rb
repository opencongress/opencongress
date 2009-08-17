require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::DeployedEnvironment do
  
  describe "mongrel" do
    
    before(:all) do
      class << self
        module ::Mongrel
          class HttpServer
            def port; 3000; end
          end
        end
      end
      
      Mongrel::HttpServer.new
      @deployed_environment = Exceptional::DeployedEnvironment.new
    end
    
    it "server should be mongrel" do
      @deployed_environment.server.should == :mongrel
    end
    
    it "identifier should be 3000" do
      @deployed_environment.identifier.should == 3000
    end
    
    it "to_s should match" do
      pending
      @deployed_environment.to_s.should match(/(:3000 \[:mongrel\])/)
    end
    
    it "mode should be queue" do
      @deployed_environment.determine_mode.should == :queue
    end
    
    after(:all) do
      ObjectSpace.garbage_collect
    end

  end
 
  describe "webrick" do

    before(:all) do
      class MockOptions
        def fetch(*args)
          3001
        end
      end
      
      class << self
        ::OPTIONS = MockOptions.new
        ::DEFAULT_PORT = 3000
      end
      @deployed_environment = Exceptional::DeployedEnvironment.new
    end
    
    it "server should be webrick" do
      @deployed_environment.server.should == :webrick
    end
    
    it "identifier should be 3001" do
      @deployed_environment.identifier.should == 3001
    end
    
    it "mode should be queue" do
      @deployed_environment.determine_mode.should == :queue
    end
    
    after(:all) do
      ObjectSpace.garbage_collect
      Object.class_eval { remove_const :OPTIONS }
      Object.class_eval { remove_const :DEFAULT_PORT }
    end
    
  end
  
  describe "thin" do
    
    before(:all) do
      class << self
        module ::Thin
          class Server
            def backend; self; end
            def socket; "/socket/file.000"; end
          end
        end
      end
      Thin::Server.new
      
      @deployed_environment = Exceptional::DeployedEnvironment.new
    end
    
    it "server should be thin" do
      @deployed_environment.server.should == :thin
    end
    
    it "identifier should be the socket file" do
      @deployed_environment.identifier.should == '/socket/file.000'
    end
    
    it "mode should be queue" do
      @deployed_environment.determine_mode.should == :queue
    end
    
    after(:all) do
      ObjectSpace.garbage_collect
    end
    
  end
  
  describe "litespeed" do
    
    before(:all) do
      @deployed_environment = Exceptional::DeployedEnvironment.new
    end
    
    # Hmmph, how to determine if we're running under litespeed...
    it "server should be unknown" do
      @deployed_environment.server.should == :unknown
    end
    
    it "identifier should be nil" do
      @deployed_environment.identifier.should == nil
    end
    
    it "mode should be queue" do
      @deployed_environment.determine_mode.should == :queue
    end
    
    after(:all) do
      ObjectSpace.garbage_collect
    end
    
  end
  
  describe "passenger" do
    
    before(:all) do
      class << self
        module ::Passenger
          const_set "AbstractServer", 0
        end
      end
      @deployed_environment = Exceptional::DeployedEnvironment.new
    end
    
    it "server should be passenger" do
      @deployed_environment.server.should == :passenger
    end
    
    # Would be nicer to identify passenger by some
    it "identifier should be passenger" do
      @deployed_environment.identifier.should == 'passenger'
    end
    
    it "mode should be queue" do
      @deployed_environment.determine_mode.should == :direct
    end
    
    after(:all) do
      ObjectSpace.garbage_collect
    end
    
  end
  
end
