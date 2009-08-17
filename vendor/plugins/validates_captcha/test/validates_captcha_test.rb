require 'test/unit'
RAILS_ENV = "test"
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'RMagick'
require 'captcha_config'
require 'captcha_challenge'
require 'captcha_question_challenge'
require 'captcha_image_challenge'
require 'test/mock_model'

FleskPlugins::CaptchaConfig.config['i_will_test_validation_myself_thank_you_very_much'] = true

class ValidatesCaptchaTest < Test::Unit::TestCase
  include FleskPlugins
  
  def test_question_challenge_create
    c = CaptchaQuestionChallenge.new(:question => 'Is this a test?', :answer => 'yes')
    assert_equal 'Is this a test?', c.question
    assert_equal 'yes', c.answer
    assert c.correct?('yes')
    assert_equal false, c.expired?
    assert_equal c, CaptchaChallenge.find(c.id)
  end
  
  def test_image_challenge_create
    c = CaptchaImageChallenge.new(:string => 'test')
    assert_equal 'test', c.string
    assert c.correct?('test')
    assert_equal false, c.expired?
    assert_equal c, CaptchaChallenge.find(c.id)
  end
  
  def test_image_challenge_write
    c = CaptchaImageChallenge.new(:string => 'test')
    c.generate
    c.write
    assert_not_nil c.image
    assert c.image.is_a?(Magick::Image)
    assert File.exists?(File.join(CaptchaImageChallenge::WRITE_DIR, c.file_path))
  end
  
  def test_model_validation_failure
    c = CaptchaQuestionChallenge.new(:question => 'Is this a test?', :answer => 'yes')
    m = MockModel.new(:captcha_id => c.id, :captcha_validation => 'no')
    assert !m.valid?
  end
  
  def test_model_validation_success
    c = CaptchaQuestionChallenge.new(:question => 'Is this a test?', :answer => 'yes')
    m = MockModel.new(:captcha_id => c.id, :captcha_validation => c.answer)
    assert m.valid?
  end
  
end
