require File.dirname(__FILE__) + '/../spec_helper'

describe Article do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    Article.create!(@valid_attributes)
  end

  it "should return articles for a given tag" do
    finreg1 = Article.find_by_title("Will the Agriculture Committee Hand Wall Street a Big Win on Derivatives?")
    
    articles = Article.tagged_with("Financial Reform")
    
    articles.should include(finreg1)
  end

  it "should return articles for a given tag regardless of case" do
    finreg1 = Article.find_by_title("Will the Agriculture Committee Hand Wall Street a Big Win on Derivatives?")
    finreg2 = Article.find_by_title("House Dems take on Wall Street Bonuses")
    
    articles = Article.tagged_with("Financial Reform")
    
    articles.should include(finreg1)
    articles.should include(finreg2)
  end
end
