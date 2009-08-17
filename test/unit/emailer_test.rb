require File.dirname(__FILE__) + '/../test_helper'
require 'emailer'

class EmailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_send_sponsors
    to, from, subj, msg = ['pcfneil'], ['visitor@opencongress.org'], 'Some bill', 'text'
    @expected.to = to
    @expected.subject = subj
    @expected.from = from
    @expected.body = msg
    @expected.date = Time.now
    response = Emailer.create_send_sponsors(to, from, subj, msg, @expected.date)
    #response = Emailer.deliver_send_sponsors(to, from, subj, msg, @expected.date).encoded
    assert_equal(response.subject, subj)
    assert_equal(response.to, to)
    assert_equal(response.from, from)
    assert_equal(response.body, msg)
    assert_equal(response.encoded, @expected.encoded)
  end

  def test_send_person
    to, from, subj, msg = ['pcfneil'], ['visitor@opencongress.org'], 'Some bill', 'text'
    @expected.to = to
    @expected.subject = subj
    @expected.from = from
    @expected.body = msg
    @expected.date = Time.now
    response = Emailer.create_send_person(to, from, subj, msg, @expected.date)
    assert_equal(response.subject, subj)
    assert_equal(response.to, to)
    assert_equal(response.from, from)
    assert_equal(response.body, msg)
    assert_equal(response.encoded, @expected.encoded)
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/emailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
