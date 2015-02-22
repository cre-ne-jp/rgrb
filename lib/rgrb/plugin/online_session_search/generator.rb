# vim: fileencoding=utf-8

require 'uri'
require 'open-uri'
require 'json'

require 'rgrb/plugin/online_session_search/session'

module RGRB
  module Plugin
    # オンラインセッション情報検索プラグイン
    module OnlineSessionSearch
      # OnlineSessionSearch の出力テキスト生成器
      class Generator
        # セッションマッチングシステム JSON 形式データの URL
        SESSION_JSON_URL = 'http://session.trpg.net/json.php'

        def latest_schedules(n = 5)
          url = "#{SESSION_JSON_URL}?n=#{n}"

          session_data_from(url)
        end

        def search(str, n = 5)
          params = {
            s: str,
            n: n
          }
          url = "#{SESSION_JSON_URL}?#{URI.encode_www_form(params)}"

          session_data_from(url)
        end

        def session_data_from(url)
          json = open(url, 'r:UTF-8') { |f| f.read }
          sessions = Session.parse_json(json)
          format(sessions)
        end
        private :session_data_from

        def format(sessions)
          if sessions.empty?
            ['開催予定のセッションは見つかりませんでしたの☆']
          else
            sessions.map do |session|
              n_members_str =
                if session.min_members == session.max_members
                  "#{session.max_members}人"
                else
                  "#{session.min_members}-#{session.max_members}人"
                end
              params = [
                session.start_time.localtime('+09:00').strftime('%F %R'),
                n_members_str,
                session.url
              ]

              "#{session.game_system} / #{session.name} " \
                "(#{params.join('; ')})"
            end
          end
        end
        private :format
      end
    end
  end
end
