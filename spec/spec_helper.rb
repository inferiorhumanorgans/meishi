# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'

SimpleCov.start do
  # Ignore our specs
  add_filter do |file|
    file.filename.sub(/^#{Rails.root.to_s}\//, '') =~ /^spec/
  end

  # Ignore our config files
  add_filter do |file|
    fn = file.filename.sub(/^#{Rails.root.to_s}\//, '')
    (fn =~ /^config/)
  end

  
  add_group "Models (ActiveRecord)" do |file|
    fn = file.filename.sub(/^#{Rails.root.to_s}\//, '')
    (fn =~ /^app\/models/) and !(fn =~ /app\/models\/carddav/)
  end

  add_group "Models (dav4rack)" do |file|
    fn = file.filename.sub(/^#{Rails.root.to_s}\//, '')
    (fn =~ /^app\/models\/carddav/)
  end

  add_group "Controllers (ActionController)" do |file|
    fn = file.filename.sub(/^#{Rails.root.to_s}\//, '')
    (fn =~ /^app\/controllers/) and !(fn =~ /app\/controllers\/carddav/)
  end

  add_group "Controllers (dav4rack)" do |file|
    fn = file.filename.sub(/^#{Rails.root.to_s}\//, '')
    (fn =~ /^app\/controllers\/carddav/)
  end

  # add_group "CardDAV" do |file|
  #   fn = file.filename.sub(/^#{Rails.root.to_s}\//, '')
  #   (fn =~ /^app\/(controllers|models)\/carddav/)
  # end

  # add_group 'Views', 'app/views'
  add_group 'Helpers', 'app/helpers'
  # add_group "Initializers", 'config/initializers'
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include Devise::TestHelpers, :type => :controller
  config.include Rails.application.routes.url_helpers

  # This is gross.
  config.include ControllerMacros, :type => :controller
  config.extend ControllerMacros, :type => :controller
end