source 'https://rubygems.org'

gem 'activesupport', '~> 5.0'
gem 'twitter', '~> 6.2'
gem 'lumberjack', '~> 1.0'
gem 'sysexits', '~> 1.2'
gem 'http', '> 3.0'
gem 'guess_html_encoding'
gem 'charlock_holmes', '~> 0.7'
gem 'nokogiri', '~> 1.6'
gem 'd1lcs'
gem 'json'
gem 'mail', '~> 2.7'

group :irc do
  gem 'cinch'

  # DiceRollプラグインで使用する
  gem 'gdbm'
end

group :discord do
  gem 'discordrb'
end

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'yard', '~> 0.8'
  gem 'rubocop', '~> 0.28'
end

group :test do
  gem 'rake', '~> 12.0'
  gem 'rspec', '~> 3.1'
  gem 'coveralls', require: false
  gem 'webmock', '~> 3.3'
end

# パス設定
[
  'lib',
  'vendor'
].each do |lib_name|
  lib_path = File.expand_path(lib_name, File.dirname(__FILE__))
  $LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
end
