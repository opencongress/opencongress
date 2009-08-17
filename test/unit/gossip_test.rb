require File.dirname(__FILE__) + '/../test_helper'

class GossipTest < Test::Unit::TestCase
  fixtures :gossip #actually uses a fixture!

  def test_post_gossip
    g = Gossip.create :name => "Ben", :email => "ben@matasar.org", :link => "http://www.govtrack.us", :tip => "Great website!"
    assert !g.new_record?
    assert_not_nil g.created_at
  end

  def test_invalid_gossip
    g = Gossip.create :name => "Ben", :email => "ben@matasar.org", :link => "http://www.govtrack.us", :title => ''
    assert g.new_record?, "Validation didn't work: missing title and still saved"
  end

  def test_latest
    assert Gossip.latest.size == 10
  end

  def test_frontpage
    assert Gossip.frontpage.size == 2
  end

  def test_tip_html
    g = Gossip.create :name => "Ben", :email => "ben@matasar.org", :link => "http://www.govtrack.us", :tip => "Great website!"
    assert g.tip_html.match(/Great website/)
    assert g.tip_html.match(/<p>/)
  end

end
