require 'test_helper'
require 'lazy_document'

class UserModel; end

class LazyDocumentTest < Test::Unit::TestCase
  context "With a lazy document" do
    setup do
      @record = stub(:record)
      @record.stubs(:is_valid?).returns true
      UserModel.stubs(:find).returns @record
      @document = ActsAsSolr::LazyDocument.new(1, UserModel)
    end
    
    context "with an uninitialized document" do
      should "fetch the record from the database" do
        UserModel.expects(:find).with(1).returns(@record)
        @document.is_valid?
      end
    end
    
    context "with an initialized document" do
      should "not fetch the record again" do
        @document.is_valid?
        @document.expects(:find).never
        @document.is_valid?
      end
      
      should "reroute the calls to the record" do
        @record.expects(:is_valid?).once
        @document.is_valid?
      end
    end
  end
end
