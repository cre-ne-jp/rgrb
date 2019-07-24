# vim: fileencoding=utf-8

require 'rgrb/plugin_base/generator'
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
        include PluginBase::Generator

        # 生成器を初期化する
        def initialize
          super

          @version_and_commit_id = get_version_and_commit_id
          logger.warn("BCDice を読み込みました: #{bcdice_version}")

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
          dice_bot = find_dice_bot(game_type)
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
          "BCDice Version: #{@version_and_commit_id}"
        end

        private

        # 起動時点での BCDice のコミット ID を取得・保存する
        # @return [String]
        def get_version_and_commit_id
          bcdice_path = File.expand_path('../../../../vendor/BCDice', __dir__)
          @commit_id =
            begin
              Dir.chdir(bcdice_path) do
                `git show -s --format=%H`.strip
              end
            rescue
                ''
            end

          @commit_id.empty? ? $bcDiceVersion : "#{$bcDiceVersion} (#{@commit_id})"
        end

        # ダイスボットを探す
        # @param [String] game_type ゲームタイプ
        # @return [DiceBot]
        def find_dice_bot(game_type)
          if game_type == 'DiceBot'
            DiceBot.new
          else
            DiceBotLoaderList.find(game_type)&.loadDiceBot ||
              DiceBotLoader.loadUnknownGame(game_type)
          end
        end
      end
    end
  end
end
