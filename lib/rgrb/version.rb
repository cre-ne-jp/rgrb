# vim: fileencoding=utf-8

module RGRB
  # RGRB のバージョン番号
  VERSION_NUMBER = '0.12.1'

  # コミットID取得
  # エラーが発生した場合は、返り値にコミットIDが含まれない。
  COMMIT_ID =
    begin
      Dir.chdir(File.dirname(File.expand_path(__FILE__))) do
        `git show -s --format=%H`.strip
      end
    rescue
      ''
    end

  # バージョンとコミットIDを表す文字列を返す
  VERSION = COMMIT_ID.empty? ? VERSION_NUMBER : "#{VERSION_NUMBER} (#{COMMIT_ID})"
end
