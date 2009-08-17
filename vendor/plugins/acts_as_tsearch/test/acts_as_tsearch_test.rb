#########################################
# To run this you first need to create a database and set it up for tsearch.
# 
# Tsearch comes with Postgres now.  From terminal try a "locate tsearch2.sql".  If nothing is found then you need
# recompile postgres.  More information on that coming.
# 
# If you found tsearch2.sql then you just need to do this:
# >> su postgres  (or su root, then su postgres - if you don't know the postgres password)
# >> psql acts_as_tsearch_test < tsearch2.sql
# >> psql acts_as_tsearch_test
# 	grant all on public.pg_ts_cfg to acts_as_tsearch_test;
# 	grant all on public.pg_ts_cfgmap to acts_as_tsearch_test;
# 	grant all on public.pg_ts_dict to acts_as_tsearch_test;
# 	grant all on public.pg_ts_parser to acts_as_tsearch_test;
#
#########################################
require File.dirname(__FILE__) + '/test_helper'

class ActsAsTsearchTest < Test::Unit::TestCase

  def setup
    create_fixtures(:blog_entries, :blog_comments, :profiles)
  end  
  
  # Is your db setup properly for tests?
  def test_is_db_working
    assert BlogEntry.count > 0
  end

  def test_empty_search
    BlogEntry.acts_as_tsearch :fields => "title"
    BlogEntry.update_vectors

    assert_raise ActiveRecord::RecordNotFound do
      b = BlogEntry.find_by_tsearch(nil)
    end

    assert_raise ActiveRecord::RecordNotFound do
      b = BlogEntry.find_by_tsearch("")
    end
  end
  
  # Do the most basic search
  def test_simple_search
    BlogEntry.acts_as_tsearch :fields => "title"
    BlogEntry.update_vectors
    b = BlogEntry.find_by_tsearch("bob")[0]
    assert b.id == 1, b.to_yaml
  end

  def test_scoped_search
    BlogEntry.acts_as_tsearch :fields => "title"
    BlogEntry.update_vectors
    b = BlogEntry.scoped_by_tsearch("bob").find(:first)
    assert b.id == 1, b.to_yaml
  end

  # Do a simple multi-field search
  def test_simple_two_field
    BlogEntry.acts_as_tsearch :fields => [:title, :description]
    BlogEntry.update_vectors
    b = BlogEntry.find_by_tsearch("bob")[0]
    assert b.id == 1, b.to_yaml
    b = BlogEntry.find_by_tsearch("dined")[0]
    assert b.id == 1, b.to_yaml
    assert BlogEntry.find_by_tsearch("shared").size == 2
    b = BlogEntry.find_by_tsearch("zippy")[0]
    assert b.id == 2, b.to_yaml
  end
  
  # Do a simple multi-field search
  def test_weight_syntax
    BlogEntry.acts_as_tsearch :vectors => {
                        :fields => {
                          "a" => {:columns => ["title"], :weight => 1},
                          "b" => {:columns => [:description], :weight => 0.5}
                          }
                        }
    BlogEntry.update_vectors
    b = BlogEntry.find_by_tsearch("bob")[0]
    assert b.id == 1, b.to_yaml
    b = BlogEntry.find_by_tsearch("dined")[0]
    assert b.id == 1, b.to_yaml
    assert BlogEntry.find_by_tsearch("shared").size == 2
    b = BlogEntry.find_by_tsearch("zippy")[0]
    assert b.id == 2, b.to_yaml

    BlogEntry.acts_as_tsearch :fields => {
                          "a" => {:columns => ["title"], :weight => 1},
                          "b" => {:columns => [:description], :weight => 0.5}
                          }
    BlogEntry.update_vectors
    b = BlogEntry.find_by_tsearch("bob")[0]
    assert b.id == 1, b.to_yaml
    b = BlogEntry.find_by_tsearch("dined")[0]
    assert b.id == 1, b.to_yaml
    assert BlogEntry.find_by_tsearch("shared").size == 2
    b = BlogEntry.find_by_tsearch("zippy")[0]
    assert b.id == 2, b.to_yaml
  end

  # Do a simple multi-field search
  def test_multi_table
    BlogEntry.acts_as_tsearch :vectors => {
                        :fields => {
                          "a" => {:columns => ["blog_entries.title"], :weight => 1},
                          "b" => {:columns => ["blog_comments.comment"], :weight => 0.5}
                          },
                        :tables => {
                          :blog_comments => {
                            :from => "blog_entries b2 left outer join blog_comments on blog_comments.blog_entry_id = b2.id",
                            :where => "b2.id = blog_entries.id"
                            }
                          }
                        }

    BlogEntry.update_vectors
    
    assert_nothing_raised do
      b = BlogEntry.find(1)
      b.title = "Bob ate lunch today"
      b.save!
    end
    
    b = BlogEntry.find_by_tsearch("bob")[0]
    assert b.id == 1, b.to_yaml

    b = BlogEntry.find_by_tsearch("see")[0]
    assert b.id == 1, b.to_yaml

    b = BlogEntry.find_by_tsearch("ate today")[0]
    assert b.id == 1, b.to_yaml

    b = BlogEntry.find_by_tsearch("zippy")[0]
    assert b.id == 2, b.to_yaml
    
    b = BlogEntry.find_by_tsearch("crack")[0]
    assert b.id == 2, b.to_yaml
    
  end

  # Test the auto-update functionality
  def test_add_row_and_search
    BlogEntry.acts_as_tsearch :fields => [:title, :description]
    BlogEntry.update_vectors
    b = BlogEntry.new
    b.title = "qqq"
    b.description = "xxxyyy"
    b.save
    id = b.id
    b = BlogEntry.find_by_tsearch("qqq")[0]
    assert id == b.id
    b = BlogEntry.find_by_tsearch("xxxyyy")[0]
    assert id == b.id
  end
  
  def test_count_by_search
    BlogEntry.acts_as_tsearch :fields => "title"
    BlogEntry.update_vectors
    
    assert BlogEntry.count_by_tsearch("bob") == 1
    assert BlogEntry.count_by_tsearch("bob or zippy") == 2
    assert BlogEntry.count_by_tsearch("bob and opera") == 0
  end

  def test_add_row_and_search_flag_off
    BlogEntry.acts_as_tsearch :vectors => {
      :auto_update_index => false,
      :fields => [:title, :description]
    }
    BlogEntry.update_vectors
    b = BlogEntry.new
    b.title = "uuii"
    b.description = "ppkkjj"
    b.save
    id = b.id
    assert BlogEntry.find_by_tsearch("uuii").size == 0
    assert BlogEntry.find_by_tsearch("ppkkjj").size == 0

    #update vector
    BlogEntry.update_vector(id)
    #should be able to find it now
    assert BlogEntry.find_by_tsearch("uuii")[0].id == id
    assert BlogEntry.find_by_tsearch("ppkkjj")[0].id == id
    
  end
    
  # Test for error message if user typos field names
  def test_failure_for_bad_fields
    assert_raise ArgumentError do
      BlogEntry.acts_as_tsearch :fields => "ztitle"
    end

    assert_raise ArgumentError do
      BlogEntry.acts_as_tsearch :fields => [:ztitle, :zdescription]
    end
    
    assert_raise ArgumentError do
      BlogEntry.acts_as_tsearch :vectors => {
        :auto_update_index => false,
        :fields => {          
          "a" => {:columns => [:title]},
          "b" => {:columns => [:zdescription]}
          }
        }
    end
    
  end
  
  def test_vectors
#     Profile.acts_as_tsearch :public_vector => {:fields => {"a" => {:columns => [:name, :public_info]}}},
#                             :private_vector => {:fields => {"a" => {:columns => [:name, :private_info]}}}
     Profile.acts_as_tsearch :public_vector => {:fields => [:name, :public_info]},
                             :private_vector => {:fields => [:name, :private_info]}
#raise Profile.acts_as_tsearch_config.to_yaml
    Profile.update_vectors
    p = Profile.find_by_tsearch("ben",nil,{:vector => "public_vector"})[0]
    assert p.name == "ben", "Couldn't find 'ben' in public profile search"

    assert_raise RuntimeError do
      p = Profile.find_by_tsearch("ben")[0]
    end
    
    p = Profile.find_by_tsearch("bob",nil,{:vector => "public_vector"})[0]
    assert p.name == "bob", "Couldn't find 'bob' in public profile search"

    p = Profile.find_by_tsearch("ben",nil,{:vector => "private_vector"})[0]
    assert p.name == "ben", "Couldn't find 'ben' in private profile search"
    
    p = Profile.find_by_tsearch("bob",nil,{:vector => "private_vector"})[0]
    assert p.name == "bob", "Couldn't find 'bob' in private profile search"

    p = Profile.find_by_tsearch("pumpkin",nil,{:vector => "public_vector"})
    assert p.size == 0, "Shouldn't have found pumpkin in public search: #{p.to_yaml}"
    
    p = Profile.find_by_tsearch("pumpkin",nil,{:vector => "private_vector"})[0]
    assert p.name == "ben", "Couln't find pumpkin in private profile search"
  end
  
  def test_clean_query
    #FIXME: call directly -CMB
    BlogEntry.acts_as_tsearch :fields => "title"
    assert_equal '"o\'\'reily bookstore"', BlogEntry.clean_query('"O\'Reily bookstore"')
    assert_equal '+test -test2',           BlogEntry.clean_query('+test -test2')
    assert_equal 'uppercase',              BlogEntry.clean_query('UpPerCaSe')
    assert_equal 'stripped whitespace',    BlogEntry.clean_query('   stripped whitespace    ')
    assert_equal 'reserved',               BlogEntry.clean_query('(!&|reserved)')
  end
  
  def test_query_to_terms
    #FIXME: call directly -CMB
    BlogEntry.acts_as_tsearch :fields => "title"
    assert_equal [ ['&', 'text'] ],                BlogEntry.query_to_terms('text')
    assert_equal [ ['&', 'text'], ['&', 'asdf'] ], BlogEntry.query_to_terms('text asdf')
    assert_equal [ ['&', 'text'], ['&', 'asdf'] ], BlogEntry.query_to_terms('text +asdf')
    assert_equal [ ['&', 'text'], ['&', 'asdf'] ], BlogEntry.query_to_terms('text and asdf')
    assert_equal [ ['&', 'text'], ['|', 'asdf'] ], BlogEntry.query_to_terms('text or asdf')
    assert_equal [ ['&', 'text'], ['&', '!sdf'] ], BlogEntry.query_to_terms('+text -sdf')
    
    assert_equal [ ['&', 'a'], ['&', '!b'] ], BlogEntry.query_to_terms('+a and -b')
    assert_equal [ ['&', 'a'], ['|', '!b'] ], BlogEntry.query_to_terms('+a or -b')
    
    assert_equal [ ['&', '(a)'] ],   BlogEntry.query_to_terms('"a"')
    assert_equal [ ['&', '(a)'] ],   BlogEntry.query_to_terms('"+-&|  -a  "')
    assert_equal [ ['&', '!(a)'] ],  BlogEntry.query_to_terms('-"a"')
    assert_equal [ ['&', '(a&b)'] ], BlogEntry.query_to_terms('"a  b "')
    assert_equal [ ['&', '(a&b)'] ], BlogEntry.query_to_terms('"a  b ')
    
    assert_equal [ ['&', '(a&b)'], ['|', '!(c&d&f)'] ],                     BlogEntry.query_to_terms('"a  b" or -"c d f')
    assert_equal [ ['&', '!a'], ['&', '!(c&d)'], ['|', 'b'], ['&', 'e'] ],  BlogEntry.query_to_terms('-a -"c d" or b +e')
  end
  
  def test_fix_tsearch_query
    #FIXME: call directly -CMB
    BlogEntry.acts_as_tsearch :fields => "title"
    assert_equal '', BlogEntry.fix_tsearch_query('')
    assert_equal '', BlogEntry.fix_tsearch_query('(!&|)')
    
    assert_equal '()', BlogEntry.fix_tsearch_query('""')
    assert_equal '()', BlogEntry.fix_tsearch_query('+"  &  "')
    
    assert_equal 'text', BlogEntry.fix_tsearch_query('text')
    assert_equal 'text', BlogEntry.fix_tsearch_query('  Text ')
    
    assert_equal 'searching&for&something|not',            BlogEntry.fix_tsearch_query('searching for AND something OR not')
    assert_equal 'word&(some&phrase)&!this&that|(it&was)', BlogEntry.fix_tsearch_query('word +"some phrase" -this and that or "it was')
  end

  def test_association_query_belongs_to
      BlogComment.acts_as_tsearch :fields => 'comment'
      BlogComment.update_vectors
      
      e = BlogComment.find_by_tsearch('nice')[0].blog_entry
      assert e.description.match(/while eating lunch/)
  end
  
  def test_association_query_has_many
      BlogComment.acts_as_tsearch :fields => %w{name comment}
      BlogComment.update_vectors
      
      c = BlogEntry.find(1).blog_comments.find_by_tsearch("really AND jim")
      assert_equal 1, c.size, BlogEntry.find(1).blog_comments.inspect
      assert c[0].comment.match(/^Really great/), c.inspect
  end
  
  def test_association_query_has_and_belongs_to_many
      Profile.find(1).blog_entries << BlogEntry.find(2)
      BlogEntry.acts_as_tsearch :fields => 'description'
      BlogEntry.update_vectors

      # without tsearch
      e = Profile.find(1).blog_entries.find(:all)
      assert_equal 1, e.size
      assert_equal 'Zippy', e[0].title

      # with tsearch
      e = Profile.find(1).blog_entries.find_by_tsearch('zippy')
      assert_equal 1, e.size
      assert_equal 'Zippy', e[0].title
  end

  def test_find_using_joins_option
      BlogComment.acts_as_tsearch :fields => %w{name}
      BlogComment.update_vectors

      # :joins is a seldom used .find option, that lets you add joins to the FROM clause,
      # e.g. if your tables are related by something other than PK.
      # This test case is an unconvincing example of the need for :joins :)
      c = BlogComment.find_by_tsearch('jim', :joins => 'JOIN blog_entries ON blog_entries.id = blog_comments.blog_entry_id')

      assert_equal 2, c.size
      assert_equal 'Bob eats lunch', c[0].blog_entry.title
  end

  def test_find_using_include_option
      BlogComment.acts_as_tsearch :fields => %w{name}
      BlogComment.update_vectors
  
      c = BlogComment.find_by_tsearch('jim', :include => :blog_entry)
      assert_equal 2, c.size
      assert_equal 'Bob eats lunch', c[0].blog_entry.title
  end

  def test_results_order
      BlogComment.acts_as_tsearch :fields => %w{comment}
      BlogComment.update_vectors

      c = BlogComment.find_by_tsearch('blog')
      assert_equal "2", c[0].tsearch_rank
      assert_equal "1", c[1].tsearch_rank
  end

  def test_result_order_using_include_option
      BlogComment.acts_as_tsearch :fields => %w{comment}
      BlogComment.update_vectors

      c = BlogComment.find_by_tsearch('blog', :include => :blog_entry)
      assert_equal "2", c[0].tsearch_rank
      assert_equal "1", c[1].tsearch_rank
  end

  
  def test_find_using_conditions
      BlogComment.acts_as_tsearch :fields => %w{name}
      BlogComment.update_vectors
      
      c = BlogComment.find_by_tsearch('jim', :include => :blog_entry, :conditions => "email = 'jim@jim.com'")
      assert_equal 2, c.size
      
      c = BlogComment.find_by_tsearch('jim', :include => :blog_entry, :conditions => ["email = ?", 'jim@jim.com'])
      assert_equal 2, c.size
  end
end
