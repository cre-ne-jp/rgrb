source 'https://rubygems.org'

gem 'activesupport', '~> 4.1.6'
gem 'cinch', '~> 2.1.0'
gem 'twitter', '~> 5.11.0'
gem 'hugeurl', '~> 0.0.8'
gem 'sysexits', '~> 1.1.0'

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'rspec', '~> 3.0.0'
  gem 'yard', '~> 0.8.7.4'
  gem 'redcarpet', '~> 3.1.2' # YARD での Markdown 解析に必要
  gem 'rubocop', '~> 0.24.1'
end

# パス設定
lib_path = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
