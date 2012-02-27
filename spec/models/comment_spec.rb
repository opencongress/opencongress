require 'spec_helper'

describe Comment do
  describe "spam detection" do
    let(:comment) { Comment.new }

    before(:each) do
      @article = Article.create!
  
      @user = User.new(
        :login => 'commenttest',
        :password => 'generic',
        :password_confirmation => 'generic',
        :email => "commenttest@opencongress.org",
        :zipcode => '90039',
        :enabled => true,
        :is_banned => false,
        :accept_tos => true
      )
      @user.accepted_tos = true
      @user.accepted_tos_at = Time.now
      
      @user.save
      
      @user.activate
      
      comment.commentable = @article
      comment.user = @user

      # this api key is not the same as the one used in production
      Defender.api_key = '7381e638d4d9163d409266b313dee312'
      Defender.test_mode = true
    end
    
    it "does not identify good comments as spam" do      
      comment.comment = "[innocent,0.25] But behind the public pronouncements, American officials described a growing concern, even at the highest levels of the Obama administration and Pentagon, about the challenges of pulling off a troop withdrawal in Afghanistan that hinges on the close mentoring and training of army and police forces."
      comment.save
      
      comment.is_spam?.should == false
      comment.defensio_sig.blank?.should == false
    end
    
    it "does identify spammy comments as spam" do
      comment.comment = '[spam,0.85] <a href="http://www.kigtropin-shop.com/Wholesale-hgh_c6">HGH</a> <a href="http://www.kigtropin-shop.com/Wholesale-jintropin_c1">Jintropin</a> <a href="http://www.kigtropin-shop.com/Wholesale-hygetropin_c3">Hygetropin</a> <a href="http://www.kigtropin-shop.com/Wholesale-kigtropin_c4">Kigtropin</a> <a href="http://www.kigtropin-shop.com/Wholesale-jintropin-aq_c2">Jintropin AQ</a> <a href="http://www.kigtropin-shop.com/Wholesale-hcg_c7">HCG</a>'
      comment.save
      
      comment.is_spam?.should == true
    end
  end
end