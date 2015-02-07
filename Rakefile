# vim: fileencoding=utf-8

require 'yard'

task default: :spec

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

YARD::Rake::YardocTask.new do |t|
  t.options = [
    '--title', '汎用ダイスボット RGRB'
  ]
  t.files = [
    'lib/**/*.rb',
    '-',
    'doc/*.md',
    'doc/plugins/*.md'
  ]
end
