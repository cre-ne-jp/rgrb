# vim: fileencoding=utf-8

require 'uri'
require 'open-uri'
require 'json'

module RGRB
  module Plugin
    # オンラインセッション情報検索プラグイン
    module OnlineSessionSearch
      # OnlineSessionSearch の出力テキスト生成器
      class Generator
        # セッションマッチングシステム JSON 形式データの URL
        SESSION_JSON_URL = 'http://session.trpg.net/json.php2'
        # 情報取得に失敗したときのエラーメッセージ
        GET_ERROR_MESSAGE = 'オンラインセッション情報の取得に失敗しました'

        def latest_schedules(n = 5)
          url = "#{SESSION_JSON_URL}?n=#{n}"

          begin
            session_data = get_session_data(url)
          rescue
            [GET_ERROR_MESSAGE]
          end
        end

        def search(str, n = 5)
          params = {
            s: str,
            n: n
          }
          url = "#{SESSION_JSON_URL}?#{URI.encode_www_form(params)}"

          begin
            session_data = get_session_data(url)
          rescue
            [GET_ERROR_MESSAGE]
          end
        end

        def get_session_data(url)
          json = open(url, 'r:UTF-8') { |f| f.read }
          parse(json)
        end
        private :get_session_data

        def body(session_data)
          if session_data.empty?
            ['開催予定のセッションは見つかりませんでしたの☆']
          else
          end
        end
      end
    end
  end
end
