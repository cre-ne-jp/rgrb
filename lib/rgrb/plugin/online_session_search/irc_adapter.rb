# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/online_session_search/generator'
require 'rgrb/plugin/util/notice_multi_lines'

module RGRB
  module Plugin
    module OnlineSessionSearch
      # OnlineSessionSearch の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::NoticeMultiLines

        # セッションマッチングシステムの URL
        SESSION_URL = 'http://session.trpg.net/'

        # 一覧の URL を提示するメッセージ
        LIST_MESSAGE = "一覧は #{SESSION_URL} からどうぞ♪"
        # 情報取得に失敗したときのエラーメッセージ
        GET_ERROR_MESSAGE = 'オンラインセッション情報の取得に失敗しました'

        set(plugin_name: 'OnlineSessionSearch')
        match(/ons\s*$/, method: :latest_schedules)
        match(/ons\s+(.+)/, method: :search)

        def initialize(*args)
          super

          @generator = Generator.new
        end

        # 最近追加されたセッション情報を出力する
        # @param [Cinch::Message] m
        # @return [void]
        def latest_schedules(m)
          log_incoming(m)

          messages = [
            '最近追加されたオンラインセッション情報ですわ☆',
            LIST_MESSAGE
          ]

          begin
            messages += @generator.latest_schedules(5)
          rescue => e
            bot.loggers.exception(e)
            messages << GET_ERROR_MESSAGE
          end
          notice_multi_lines(messages, m.target)
        end

        # オンラインセッションを検索する
        # @param [Cinch::Message] m
        # @param [String] str 検索キーワード
        # @return [void]
        def search(m, str)
          log_incoming(m)

          messages = [
            "オンラインセッション情報検索: #{str}",
            LIST_MESSAGE
          ]

          begin
            messages += @generator.search(str, 5)
          rescue => e
            bot.loggers.exception(e)
            messages << GET_ERROR_MESSAGE
          end
          notice_multi_lines(messages, m.target, '', true)
        end
      end
    end
  end
end
