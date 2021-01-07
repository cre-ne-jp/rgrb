require 'simplecov'
SimpleCov.start

require 'webmock/rspec'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end
