source 'https://rubygems.org'

gem 'activesupport', '~> 4.2'
gem 'cinch', '~> 2.1'
gem 'twitter', '~> 5.11'
gem 'hugeurl', '~> 0.0.8'
gem 'sysexits', '~> 1.2'

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'yard', '~> 0.8'
  gem 'rubocop', '~> 0.28'
end

group :test do
  gem 'rake', '~> 10.4'
  gem 'rspec', '~> 3.1'
  gem 'coveralls', require: false
  gem 'webmock', '~> 1.20'
end

# パス設定
lib_path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
