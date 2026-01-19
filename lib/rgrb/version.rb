# vim: fileencoding=utf-8

module RGRB
  # RGRB のバージョン
  VERSION = '1.3.13'

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
  VERSION_WITH_COMMIT_ID = COMMIT_ID.empty? ? VERSION : "#{VERSION} (#{COMMIT_ID})"
end
