source 'https://rubygems.org'

ENV['NOKOGIRI_USE_SYSTEM_LIBRARIES']='true'

gem 'rails', '~> 3.2.14'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.6'
  gem 'machinist', '>= 2.0.0.beta2'
end

group :development do
  gem 'quiet_assets'
  gem 'yard'
  gem 'redcarpet'
end

group :test do
  gem 'simplecov', :require => false
  gem 'rake'
end

gem 'jquery-rails'

gem 'unicorn'
gem 'unicode_utils'
gem 'nokogiri'
gem 'uuidtools'
gem 'vcard', '~> 0.2.0'
gem 'warden'
gem 'rails_warden'
gem 'devise'
gem 'dav4rack', :git => 'https://github.com/inferiorhumanorgans/dav4rack.git'
gem 'sys-filesystem'

gem "twitter-bootstrap-rails"

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
