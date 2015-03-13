ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = ENV['TEST_DATABASE_URL']

require 'bundler'
Bundler.require
require 'policies'
require 'capybara/webkit'
require 'capybara'
require 'database_cleaner'
require 'timecop'

Capybara.current_driver = :webkit
Capybara.app = Policies::Application

database_cleaner = DatabaseCleaner[
  :sequel,
  { connection: Policies::Database.connection }
]

# autoload :WaitForAjax, './spec/support/wait_for_ajax'

module Policies
  autoload :Factories, './spec/support/factories'
end

RSpec.configure do |config|
  # config.include WaitForAjax, js: true
  config.include Policies::Factories

  config.before(:suite) do
    database_cleaner.clean_with(:truncation)
  end

  config.before(:each) do
    database_cleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    database_cleaner.strategy = :truncation
  end

  config.before(:each) do
    database_cleaner.start
  end

  config.after(:each) do
    database_cleaner.clean
  end
end
