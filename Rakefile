# vim: fileencoding=utf-8

desc 'ドキュメント生成'
task :doc do
  rm_r 'doc', force: true
  sh 'yardoc lib --locale ja'
end
