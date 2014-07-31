# vim: fileencoding=utf-8

desc 'RSpec によるテスト'
task :test do
  exec 'bundle exec rspec -fd -c'
end

desc 'ドキュメント生成'
task :doc do
  rm_r 'doc', :force => true
  sh 'yardoc lib --locale ja'
end
