# vim: fileencoding=utf-8

require 'rgrb/plugin/bcdice/constants'
require 'rgrb/plugin/bcdice/errors'

require 'BCDice/src/cgiDiceBot'
require 'BCDice/src/diceBot/DiceBotLoader'
require 'BCDice/src/diceBot/DiceBotLoaderList'

module RGRB
  module Plugin
    # BCDice のラッパープラグイン
    module Bcdice
      # BCDice の呼び出し結果
      BcdiceResult = Struct.new(:error, :message_lines, :game_type, :game_name)

      # Bcdice の出力テキスト生成器
      class Generator
        # 生成器を初期化する
        def initialize
          @bcdice = CgiDiceBot.new
        end

        # BCDice でダイスを振った結果を返す
        # @param [String] command ダイスコマンド
        # @param [String] specified_game_type 指定されたゲームタイプ
        # @return [BcdiceResult]
        # @raise [DiceBotNotFound] ダイスボットが見つからなかった場合
        # @raise [InvalidCommandError] 無効なコマンドが指定された場合
        def bcdice(command, specified_game_type = nil)
          # ゲームタイプが指定されていなかったら DiceBot にする
          game_type = specified_game_type || 'DiceBot'
          # ダイスボットを探す
          dice_bot = DiceBotLoaderList.find(game_type)&.loadDiceBot ||
            DiceBotLoader.loadUnknownGame(game_type)
          # ダイスボットが見つからなかった場合は中断する
          raise DiceBotNotFound, game_type unless dice_bot

          result, _ = @bcdice.roll(command, game_type)
          # 結果が返ってこなかった場合は中断する
          raise InvalidCommandError.new(command, dice_bot) if result.empty?

          # 結果の行の配列
          message_lines = result.lstrip.split(' : ', 2)[1].lines

          # 結果を返す
          BcdiceResult.new(command,
                           message_lines,
                           dice_bot.gameType,
                           dice_bot.gameName)
        end

        # git submodule で組み込んでいる BCDice のバージョンを返す
        # @return [String]
        def bcdice_version
          bcdice_path = File.expand_path('../../../../vendor/BCDice', __dir__)
          commit_id = Dir.chdir(bcdice_path) do
            `git show -s --format=%H`.strip
          end

          "BCDice Commit ID: #{commit_id}"
        end
      end
    end
  end
end
