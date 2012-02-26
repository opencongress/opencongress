source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'rake', '0.8.7'

# database gems -- need both pg and mysql for app and wiki
gem 'pg'
gem 'mysql'
gem 'system_timer'

gem "settingslogic"

# HAML support
gem "haml"
gem "haml-rails"

# RABL for API / JSON
gem 'rabl'

# Background tasks
gem 'delayed_job', '~> 2.1'

# RMagick
gem 'rmagick', '2.13.1'
gem 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git'

# Image uploads
gem 'carrierwave'
gem 'fog'

# GovKit
gem "govkit"

# jammit support
gem "jammit"
gem "closure-compiler"

# paperclip -- for attaching files to requests
gem 'paperclip'


# notifier for production errors
gem "airbrake"
gem "xray", :require => "xray/thread_dump_signal_handler"

# OpenID 
gem 'ruby-openid'
gem 'rack-openid'

# JSONP middleware
gem 'rack-contrib'

# memcache
gem 'memcache'
gem 'memcache-client'

# markup tools and parsers
gem 'simple-rss'
gem 'mediacloth'
gem 'hpricot'
gem 'RedCloth'
gem 'bluecloth'
gem 'htmlentities'
gem "json"
gem "nokogiri"

# spam protection
gem "defender"

group :deployment do
  gem 'capistrano'
  gem 'capistrano-ext'
end

# new relic RPM
gem 'newrelic_rpm'

# oauth
gem 'oauth'
gem 'facebooker2'

gem 'will_paginate', '~> 3.0.pre2'

gem "validates_captcha"
gem "okkez-open_id_authentication"

gem "acts-as-taggable-on", :git => 'git://github.com/dougcole/acts-as-taggable-on.git', :branch => 'use_equality_where_possible'

gem 'mechanize'
#gem 'formageddon', '0.0.0', :require => 'formageddon', :path => '/Users/aross/Sites/formageddon'
gem 'formageddon', :git => 'git://github.com/opencongress/formageddon.git'


group :test, :development do
  gem 'autotest'
  gem 'silent-postgres'	# Quieter postgres log messages

  gem 'rspec-rails', '~> 2.4'
  gem 'cucumber', '0.8.5'
  gem 'cucumber-rails'
  gem 'webrat'
  gem 'selenium-client'

  gem 'capybara'

  gem 'autotest'

  gem 'guard'
  gem 'guard-livereload'
end

