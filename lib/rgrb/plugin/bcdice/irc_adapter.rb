# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/util/notice_multi_lines'

# NOTE: BCDiceをlibディレクトリに入れれば指定が楽になりそう
# 例：require 'BCDice/src/cgiDiceBot'
require 'rgrb/../../vendor/BCDice/src/cgiDiceBot'
require 'rgrb/../../vendor/BCDice/src/diceBot/DiceBotLoader'
require 'rgrb/../../vendor/BCDice/src/diceBot/DiceBotLoaderList'

module RGRB
  module Plugin
    # BCDice のラッパープラグイン
    module Bcdice
      # Bcdice の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::NoticeMultiLines

        # 空白（半角＋全角）を示す正規表現
        SP_RE = /[\s　]/
        # 空白の連続を示す正規表現
        SPS_RE = /#{SP_RE}+/o

        # ダイスコマンドを示す正規表現
        DICE_COMMAND_RE = %r{[-+*/()<>=\[\].@\w]+}
        # ゲームタイトルを示す正規表現
        GAME_TITLE_RE = /[\x21-\x7E]+/

        # BCDice呼び出しの正規表現
        BCDICE_RE = /#{SPS_RE}(#{DICE_COMMAND_RE})(?:#{SPS_RE}(#{GAME_TITLE_RE}))?\z/o

        set(plugin_name: 'Bcdice')
        self.prefix = '.bcdice'
        match(BCDICE_RE, method: :bcdice)
        match(/-version/, method: :version)

        def initialize(*args)
          super

          @bcdice = CgiDiceBot.new
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

          # ゲームタイトルが指定されていなかったら DiceBot にする
          game_title = specified_game_title || 'DiceBot'
          # ダイスボットを探す
          dice_bot = DiceBotLoaderList.find(game_title)&.loadDiceBot ||
            DiceBotLoader.loadUnknownGame(game_title)

          unless dice_bot
            # ダイスボットが見つからなかった場合は中断する
            message = "#{header_common}: " \
              "ゲームシステム「#{game_title}」は見つかりませんでした"

            log_notice(m.target, message)
            m.target.send(message, true)

            return
          end

          # ゲームシステム名を含むヘッダ
          header = "#{header_common}<#{dice_bot.gameName}>: "

          result, _ = @bcdice.roll(command, game_title)

          if result.empty?
            # 結果が返ってこなかった場合は中断する
            message = "#{header}コマンド「#{command}」は無効です"

            log_notice(m.target, message)
            m.target.send(message, true)

            return
          end

          # 結果の行の配列
          message_lines = result.lstrip.split(' : ', 2)[1].lines

          notice_multi_lines(message_lines, m.target, header)
        end

        # git submodule で組み込んでいる BCDice のバージョンを出力する
        # @param [Cinch::Message] m
        # @rturn [void]
        def version(m)
          log_incoming(m)

          message = 'BCDice Commit ID: '
          message += Dir.chdir(File.expand_path(
            '../../../../vendor/BCDice',
            File.dirname(__FILE__)
          )) do |path|
            `git show -s --format=%H`.strip
          end

          log_notice(m.target, message)
          m.target.send(message, true)
        end
      end
    end
  end
end
