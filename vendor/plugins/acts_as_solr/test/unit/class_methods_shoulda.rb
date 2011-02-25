require File.dirname(__FILE__) + '/test_helper'
require 'class_methods'
require 'search_results'
require 'active_support'

class User
  attr_accessor :name, :id
  def self.find(*args)
    @paul ||= User.new
    @paul.name = "Paul"
    @paul.id = 1
    @paul
  end
  
  def self.find_by_id(id)
    find
  end
  
  def self.primary_key
    "id"
  end
end

class ClassMethodsTest < Test::Unit::TestCase
  include ActsAsSolr::ClassMethods
  
  def solr_configuration
    @solr_configuration ||= {:type_field => "type_t", :primary_key_field => "id"}
  end
  
  context "when multi-searching" do
    setup do
      stubs(:name).returns("User")
    end
    
    should "include the type field in the query" do
      expects(:parse_query).with("name:paul", {:results_format => :objects}, "AND (type_t:User)")
      multi_solr_search("name:paul")
    end
    
    should "add all models in the query" do
      expects(:parse_query).with("name:paul", {:results_format => :objects, :models => ["Movie", "DVD"]}, "AND (type_t:User OR type_t:Movie OR type_t:DVD)")
      multi_solr_search("name:paul", :models => ["Movie", "DVD"])
    end
    
    should "return an empty result set if no data was returned" do
      stubs(:parse_query).returns(nil)
      result = multi_solr_search("name:paul")
      assert_equal 0, result.docs.size
    end
    
    should "return an empty result set if no results were found" do
      stubs(:parse_query).returns(stub(:total_hits => 0, :hits => []))
      result = multi_solr_search("name:paul")
      assert_equal 0, result.docs.size
    end
    
    context "with results" do
      should "find the objects in the database" do
        stubs(:parse_query).returns(stub(:total_hits => 1, :hits => ["score" => 0.12956427, "id" => ["User:1"]]))
        result = multi_solr_search("name:paul")
        
        assert_equal(User.find, result.docs.first)
        assert_equal 1, result.docs.size
      end
      
      context "when requesting ids" do
        should "return only ids" do
          loudly do
            stubs(:parse_query).returns(stub(:total_hits => 1, :hits => ["score" => 0.12956427, "id" => ["User:1"]]))
            result = multi_solr_search("name:paul", :results_format => :ids)
            assert_equal "User:1", result.docs.first["id"]
          end
        end
      end
      
      context "with scores" do
        setup do
          solr_configuration[:primary_key_field] = nil
        end
        
        should "add an accessor with the solr score" do
          stubs(:parse_query).returns(stub(:total_hits => 1, :hits => ["score" => 0.12956427, "id" => ["User:1"]]))
          result = multi_solr_search("name:paul", :scores => true)
          assert_equal 0.12956427, result.docs.first.solr_score
        end
      end
    end
  end
end