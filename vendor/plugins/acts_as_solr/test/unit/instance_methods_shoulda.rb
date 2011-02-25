require File.dirname(__FILE__) + '/test_helper'
require 'instance_methods'
require 'logger'
module Solr; end
require 'solr/xml'
require 'solr/field'
require 'solr/document'
require 'solr_instance'
require 'erb'
require 'ostruct'

class InstanceMethodsTest < Test::Unit::TestCase

  context "With a Solr record instance" do
    setup do
      @instance = SolrInstance.new
    end
    
    context "when checking whether indexing is disabled" do
    
      setup do
        @instance.configuration = {:if => true}
      end
  
      should "return true if the specified proc returns true " do
        @instance.configuration[:offline] = proc {|record| true}
        assert @instance.indexing_disabled?
      end
  
      should "return false if the specified proc returns false" do
        @instance.configuration[:offline] = proc {|record| false}
        assert !@instance.indexing_disabled?
      end
  
      should "return true if no valid offline option was specified" do
        @instance.configuration[:offline] = nil
        @instance.configuration[:if] = proc {true}
        assert !@instance.indexing_disabled?
      end
    end

    context "when validating the boost" do
      setup do
        @instance.solr_configuration = {:default_boost => 10.0}
        @instance.configuration = {:if => true}
      end
    
      should "accept and evaluate a block" do
        @instance.configuration[:boost] = proc {|record| record.boost_rate}
        assert_equal 10.0, @instance.send(:validate_boost, @instance.configuration[:boost])
      end
  
      should "accept and return a float" do
        @instance.configuration[:boost] = 9.0
        assert_equal 9.0, @instance.send(:validate_boost, @instance.configuration[:boost])
      end
  
      should "return the default float when the specified is negative" do
        @instance.configuration[:boost] = -1.0
        assert_equal 10.0, @instance.send(:validate_boost, @instance.configuration[:boost])
      end
  
      should "execute the according method when value is a symbol" do
        @instance.configuration[:boost] = :irate
        assert_equal 8.0, @instance.send(:validate_boost, @instance.configuration[:boost])
      end
  
      should "return the default boost when there is no valid boost" do
        @instance.configuration[:boost] = "boost!"
        assert_equal 10.0, @instance.send(:validate_boost, @instance.configuration[:boost])
      end
    end
  
    context "when determining the solr document id" do
      should "combine class name and id" do
        assert_equal "SolrInstance:10", @instance.solr_id
      end
    end
  
    context "when saving the instance to solr" do
      context "with indexing disabled" do
        setup do
          @instance.configuration = {:fields => [:name], :if => nil}
        end
  
        should "just return and do nothing" do
          @instance.expects(:solr_add).never
          @instance.expects(:solr_destroy).never
          assert @instance.solr_save
        end
      end
    
      context "with indexing enabled" do
        setup do
          @instance.configuration = {:fields => [:name], :if => "true", :auto_commit => true}
          @instance.stubs(:solr_commit)
          @instance.stubs(:solr_add)
          @instance.stubs(:to_solr_doc).returns("My test document")
        end

        should "add the solr document" do
          @instance.expects(:solr_add).with("My test document").once
          @instance.solr_save
        end
      
        should "commit to solr" do
          @instance.expects(:solr_commit).once
          @instance.solr_save
        end
      
        should "not commit if auto_commit is disabled" do
          @instance.configuration.merge!(:auto_commit => false)
          @instance.expects(:solr_commit).never
          @instance.solr_save
        end
      
        should "destroy the document if :if clause is false" do
          @instance.configuration.merge!(:if => "false")
          @instance.expects(:solr_destroy).once
          @instance.solr_save
        end
      end
    end
  
    context "when destroying an instance in solr" do
      setup do
        @instance.configuration = {:if => true, :auto_commit => true}
        @instance.stubs(:solr_commit)
        @instance.stubs(:solr_delete)
      end

      should "delete the instance" do
        @instance.expects(:solr_delete).with("SolrInstance:10")
        @instance.solr_destroy
      end
    
      should "commit to solr" do
        @instance.expects(:solr_commit)
        @instance.solr_destroy
      end
    
      should "not commit if auto_commit is disabled" do
        @instance.configuration.merge!(:auto_commit => false)
        @instance.expects(:solr_commit).never
        @instance.solr_destroy
      end
      
      context "with indexing disabled" do
        should "not contact solr" do
          @instance.configuration.merge!(:offline => true, :if => nil)
          @instance.expects(:solr_delete).never
          @instance.solr_destroy
        end
      end
    end
  
    context "when converting an instance to a solr document" do
      setup do
        @instance.configuration = {:if => true, :auto_commit => true, :solr_fields => {:name => {:boost => 9.0}}, :boost => 10.0}
        @instance.solr_configuration = {:type_field => "type", :primary_key_field => "pk_id", :default_boost => 25.0}
      end
    
      should "add a document boost" do
        assert_equal 10, @instance.to_solr_doc.boost
      end
      
      should "set the solr id" do
        assert_equal "SolrInstance:10", @instance.to_solr_doc[:id]
      end
      
      should "set the type field" do
        assert_equal "SolrInstance", @instance.to_solr_doc[:type]
      end
      
      should "set the primary key fields" do
        assert_equal("10", @instance.to_solr_doc[:pk_id])
      end
      
      should "add the includes if they were configured" do
        @instance.configuration.merge! :include => [:author]
        @instance.expects(:add_includes)
        @instance.to_solr_doc
      end
      
      context "with indexed fields" do
        should "add fields with type" do
          assert_equal "Chunky bacon!", @instance.to_solr_doc[:name_s]
        end
        
        should "add the field boost" do
          field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "name_s"}
          assert_equal 9.0, field.boost
        end
        
        should "set the default boost for the field, if none is configured" do
          @instance.configuration[:solr_fields][:name][:boost] = nil
          field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "name_s"}
          assert_equal 25.0, field.boost
        end
        
        should "not overwrite the type or id field" do
          @instance.configuration[:solr_fields] = {:type => {}, :id => {}}
          doc = @instance.to_solr_doc
          assert_not_equal "humbug", doc[:type]
          assert_not_equal "bogus", doc[:id]
        end
        
        should "set the default value if field value is nil" do
          @instance.name = nil
          @instance.expects(:set_value_if_nil).with('s')
          @instance.to_solr_doc
        end
        
        should "not include nil values" do
          @instance.name = ""
          @instance.stubs(:set_value_if_nil).returns ""
          assert_nil @instance.to_solr_doc[:name_s]
        end
        
        should "escape the contents" do
          @instance.name = "<script>malicious()</script>"
          assert_equal "&lt;script&gt;malicious()&lt;/script&gt;", @instance.to_solr_doc[:name_s]
        end

        should "use an alternate field name if specified in options" do
          @instance.stubs(:nickname_for_solr).returns('Nick')
          @instance.configuration[:solr_fields].merge! :nickname => {:as => :alias}
          doc = @instance.to_solr_doc
          assert_not_nil @instance.to_solr_doc.fields.find {|f| f.name.to_s == "alias_s"}
          assert_nil     @instance.to_solr_doc.fields.find {|f| f.name.to_s == "nickname_s"}
        end

        context "when associations are included" do
          setup do
            class AssocLabel < String
              @@singular = {'people' => 'person'}
              def to_s
                self
              end
              def singularize
                @@singular[self]
              end
            end
            @assoc = AssocLabel.new('people')
            person = {:name => 'Hank Venture', :address => 'Venture Compound'}
            @people = [OpenStruct.new(person.merge(:attributes => person))]
            @instance.stubs(:people).returns(@people)
            @reflection = OpenStruct.new(:macro => :has_many)
            @instance.class.stubs(:reflect_on_association).returns(@reflection)
            @instance.configuration[:solr_includes] = {@assoc => {}}
            @instance.solr_configuration.merge! :default_boost => 35.0
          end

          should "set the default name for the include, if none is configured" do
            @instance.configuration[:solr_includes] = {@assoc => {:type => :text}}
            doc = @instance.to_solr_doc
            assert_not_nil doc.fields.find {|f| f.name.to_s == "person_s"}
          end

          should "add the include alias" do
            @instance.configuration[:solr_includes] = {@assoc => {:as => :human, :type => :text}}
            doc = @instance.to_solr_doc
            assert_not_nil doc.fields.find {|f| f.name.to_s == "human_s"}
            assert_nil     doc.fields.find {|f| f.name.to_s == "person_s"}
          end

          should "add the include type" do
            @instance.configuration[:solr_includes] = {@assoc => {:type => :date}}
            @instance.expects(:get_solr_field_type).with(){|v| true}.at_least_once.returns('s')
            @instance.expects(:get_solr_field_type).with(:date).once.returns('d')
            doc = @instance.to_solr_doc
          end

          should "set the default boost for the include, if none is configured" do
            # @instance.configuration[:solr_includes] = {@assoc => {}}
            field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "person_s"}
            assert_equal 35.0, field.boost
          end

          should "add the include boost" do
            @instance.configuration[:solr_includes] = {@assoc => {:boost => 10.0}}
            field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "person_s"}
            assert_equal 10.0, field.boost
          end

          should "default to a field value with all association attributes" do
            # @instance.configuration[:solr_includes] = {@assoc => {}}
            field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "person_s"}
            @people.first.attributes.each do |attr, value|
              assert_match /#{attr}=#{value}/, field.value
            end
          end

          should "use a field value from an association method, if one is configured" do
            @instance.configuration[:solr_includes] = {@assoc => {:using => :name}}
            field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "person_s"}
            assert_equal @people.first.name, field.value
          end

          should "use a field value from a proc, if one is configured" do
            @instance.configuration[:solr_includes] = {@assoc => {:using => lambda{|r| r.name.reverse}}}
            field = @instance.to_solr_doc.fields.find {|f| f.name.to_s == "person_s"}
            assert_equal @people.first.name.reverse, field.value
          end

          should "join multiple values into a single field unless the :multivalued options is specified" do
            @instance.configuration[:solr_includes] = {@assoc => {:multivalued => :true}}
            second_person = {:name => 'Dean Venture', :address => 'Venture Compound'}
            @people << OpenStruct.new(second_person.merge(:attributes => second_person))
            fields = @instance.to_solr_doc.fields.select {|f| f.name.to_s == "person_s"}
            assert_equal @people.size, fields.size
          end

          should "include multiple values separately if the :multivalued options is specified"    do
            # @instance.configuration[:solr_includes] = {@assoc => {}}
            second_person = {:name => 'Dean Venture', :address => 'Venture Compound'}
            @people << OpenStruct.new(second_person.merge(:attributes => second_person))
            fields = @instance.to_solr_doc.fields.select {|f| f.name.to_s == "person_s"}
            assert_not_equal @people.size, fields.size
            assert_equal 1, fields.size
          end
        end
      end
    end
  end
end