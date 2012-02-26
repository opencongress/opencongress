require 'spec_helper'

describe Bill do
  describe 'long_type_to_short' do
    it "shortens known bill types" do
      Bill.long_type_to_short("H. Res.").should == 'hr'
    end

    it "returns nil for unknown bill types" do
      Bill.long_type_to_short("Fake Bill Type").should be_nil
    end
  end

  describe "related_articles" do
    let(:bill) { Bill.new }

    before(:each) do
      @article = Article.create!
      @article.tag_list = 'foo,bar,baz'
      @article.save!
    end

    it "finds related articles" do
      bill.stub(:subject_terms).and_return("foo")
      bill.related_articles.should == [@article]
    end

    it "can match on multiple tags" do
      bill.stub(:subject_terms).and_return("foo,bar")
      bill.related_articles.should == [@article]
    end

    it "must match all of a bill's subjects" do
      bill.stub(:subject_terms).and_return("foo,bar,other")
      bill.related_articles.should be_empty
    end

    it "won't match if there are no matching tags" do
      bill.stub(:subject_terms).and_return("other")
      bill.related_articles.should be_empty
    end

    it "won't match if there are no tags" do
      bill.stub(:subject_terms).and_return("")
      bill.related_articles.should be_empty
    end
  end
end

