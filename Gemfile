source 'https://rubygems.org'

gem 'cinch', '~> 2.1.0'
gem 'redis', '~> 3.1.0'
gem 'redis-namespace', '~> 1.5.0'

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'rspec', '~> 3.0.0'
end

# パス設定
lib_path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
