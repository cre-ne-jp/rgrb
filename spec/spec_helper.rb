require 'simplecov'

SimpleCov.start do
  enable_coverage(:branch)
  add_filter('/spec/')
end

require 'webmock/rspec'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end
