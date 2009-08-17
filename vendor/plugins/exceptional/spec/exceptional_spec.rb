require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional do
  
  describe "with no configuration" do
    it "should connect to getexceptional.com by default" do
      Exceptional.remote_host.should == "getexceptional.com"
    end
    
    it "should connect to port 80 by default" do
      Exceptional.remote_port.should == 80
    end
    
    it "should parse exception into exception data object" do
     exception = mock(Exception, :message => "Something bad has happened", :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"])
     exception_data = Exceptional.parse(exception)
     exception_data.kind_of?(Exceptional::ExceptionData).should be_true
     exception_data.exception_message.should == exception.message
     exception_data.exception_backtrace.should == exception.backtrace
     exception_data.exception_class.should == exception.class.to_s 
    end
    
    it "should post exception" do
      exception_data = mock(Exceptional::ExceptionData, :message => "Something bad has happened", :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"], :class => Exception)
      Exceptional.should_receive(:call_remote, :with => [:errors, exception_data])
      Exceptional.post(exception_data)
    end
    
    it "should catch exception" do
      exception = mock(Exception, :message => "Something bad has happened", :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"])
      exception_data = mock(Exceptional::ExceptionData, :message => "Something bad has happened", :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"], :class => Exception)
      Exceptional.should_receive(:parse, :with => [exception]).and_return(exception_data)
      Exceptional.should_receive(:post, :with => [exception_data])
      Exceptional.catch(exception)
    end
    
    it "should raise a license exception if api key is not set" do
      exception_data = mock(Exceptional::ExceptionData, :message => "Something bad has happened", :backtrace => ["/app/controllers/buggy_controller.rb:29:in `index'"], :class => Exception)
      Exceptional.api_key.should == nil
      lambda { Exceptional.post(exception_data) }.should raise_error(Exceptional::LicenseException)    
    end
    
  end
  
  describe "with a custom host" do
    
    it "should overwrite default host" do
      Exceptional.remote_host = "localhost"
      Exceptional.remote_host.should == "localhost"
    end
    
    it "should overwrite default port" do
      Exceptional.remote_port = 3000
      Exceptional.remote_port.should == 3000
      Exceptional.remote_port = nil
    end
  end
  
  describe "with ssl enabled" do
    
    it "should connect to port 443" do
      Exceptional.ssl_enabled = true
      Exceptional.remote_port.should == 443
    end
    
  end
end
