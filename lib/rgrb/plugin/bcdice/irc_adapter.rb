# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/util/notice_multi_lines'
require 'rgrb/plugin/bcdice/constants'
require 'rgrb/plugin/bcdice/errors'
require 'rgrb/plugin/bcdice/generator'

require 'BCDice/src/cgiDiceBot'
require 'BCDice/src/diceBot/DiceBotLoader'
require 'BCDice/src/diceBot/DiceBotLoaderList'

module RGRB
  module Plugin
    module Bcdice
      # Bcdice の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::NoticeMultiLines

        set(plugin_name: 'Bcdice')
        self.prefix = '.bcdice'
        match(BCDICE_RE, method: :bcdice)
        match(/-version/, method: :version)

        def initialize(*args)
          super

          @generator = Generator.new
          @header = 'BCDice'
        end

        # BCDice でダイスを振る
        # @param [Cinch::Message] m 送信されたメッセージ
        # @param [String] command ダイスコマンド
        # @param [String] specified_game_title 指定されたゲームタイトル
        # @return [void]
        def bcdice(m, command, specified_game_title)
          log_incoming(m)

          # 共通のヘッダ
          header_common = "#{@header}[#{m.user.nick}]"

          result =
            begin
              @generator.bcdice(command, specified_game_title)
            rescue => e
              header = e.respond_to?(:game_name) ?
                "#{header_common}<#{e.game_name}>" : header_common
              message = "#{header}: #{e.message}"

              log_notice(m.target, message)
              m.target.send(message, true)

              return
            end

          # ゲームシステム名を含むヘッダ
          header = "#{header_common}<#{result.game_name}>: "

          notice_multi_lines(result.message_lines, m.target, header)
        end

        # git submodule で組み込んでいる BCDice のバージョンを出力する
        # @param [Cinch::Message] m
        # @return [void]
        def version(m)
          log_incoming(m)

          message = @generator.bcdice_version

          log_notice(m.target, message)
          m.target.send(message, true)
        end
      end
    end
  end
end
