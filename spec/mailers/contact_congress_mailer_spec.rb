require 'spec_helper'

describe ContactCongressMailer do
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear
  end

  describe 'reply_received_email' do
    it "sends an email" do
      contact_congress_letter = stub('ccl',
        :user => stub(:email => 'user@example.com'),
        :subject => 'letter subject'
      )
      thread = stub('thread',
                    :formageddon_recipient => stub(:title => 'Mr.', :lastname => 'Smith')
                   )
      ContactCongressMailer.reply_received_email(contact_congress_letter, thread).deliver
      @emails.first.subject.should include('Mr. Smith')
      @emails.first.to.should include('user@example.com')
    end
  end
end
