require File.dirname(__FILE__) + '/test_helper'
require 'acts_methods'
require 'mocha'

class ActsMethodsTest < Test::Unit::TestCase
  class Model
    attr_accessor :birthdate
    
    def initialize(birthdate)
      @birthdate = birthdate
    end
    
    def self.configuration
      @configuration ||= {:solr_fields => {}}
    end

    def self.columns_hash=(columns_hash)
      @columns_hash = columns_hash
    end
    
    def self.columns_hash
      @columns_hash
    end
    
    def [](key)
      @birthday
    end
    
    self.extend ActsAsSolr::ActsMethods
  end
  
  
  context "when getting field values" do
    setup do
      Model.columns_hash = {"birthdate" => stub("column", :type => :date)}
      Model.send(:get_field_value, :birthdate)
    end
    
    should "define an accessor methods for a solr converted value" do
      assert Model.instance_methods.include?("birthdate_for_solr")
    end
    
    context "for date types" do
      setup do
        @model = Model.new(Date.today)
      end
      
      should "return nil when field is nil" do
        @model.birthdate = nil
        assert_nil @model.birthdate_for_solr
      end
      
      should "return the formatted date" do
        assert_equal Date.today.strftime("%Y-%m-%dT%H:%M:%SZ"), @model.birthdate_for_solr
      end
    end
    
    context "for timestamp types" do
      setup do
        @now = Time.now
        @model = Model.new(@now)
      end
      
      should "return a formatted timestamp string for timestamps" do
        assert_equal @now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), @model.birthdate_for_solr
      end
    end
  end
  
end