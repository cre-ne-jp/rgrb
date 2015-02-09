# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/online_session_search/generator'

module RGRB
  module Plugin
    module OnlineSessionSearch
      # OnlineSessionSearch の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        # セッションマッチングシステムの URL
        SESSION_URL = 'http://session.trpg.net/'
        # 一覧の URL を提示するメッセージ
        LIST_MESSAGE = "一覧は #{SESSION_URL} からどうぞ♪"

        set(plugin_name: 'OnlineSessionSearch')
        match(/ons\s*$/, method: :latest_schedules)
        match(/ons\s+(.+)/, method: :search)

        def initialize(*args)
          super

          @generator = Generator.new
        end

        def latest_schedules(m)
          m.target.send(
            '最近追加されたオンラインセッション情報ですわ☆', true
          )
          m.target.send(LIST_MESSAGE, true)

          messages = @generator.latest_schedules(5)
          messages.each do |s|
            m.target.send(s, true)
          end
        end

        def search(m, str)
          m.target.safe_send(
            "オンラインセッション情報検索: #{str}", true
          )
          m.target.send(LIST_MESSAGE, true)

          messages = @generator.search(str, 5)
          messages.each do |s|
            m.target.send(s, true)
          end
        end
      end
    end
  end
end
