source 'https://rubygems.org'

gem 'activesupport', '~> 5.0'
gem 'cinch'
gem 'twitter', '~> 5.15'
gem 'lumberjack', '~> 1.0'
gem 'sysexits', '~> 1.2'
gem 'http', '~> 0.9'
gem 'guess_html_encoding'
gem 'charlock_holmes', '~> 0.7'
gem 'nokogiri', '~> 1.6'
gem 'd1lcs'
gem 'mail', '~> 2.6.3'

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'yard', '~> 0.8'
  gem 'rubocop', '~> 0.28'
end

group :test do
  gem 'rake', '~> 12.0'
  gem 'rspec', '~> 3.1'
  gem 'coveralls', require: false
  gem 'webmock', '~> 2.3'
end

# パス設定
lib_path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
