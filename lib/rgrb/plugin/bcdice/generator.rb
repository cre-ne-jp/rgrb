# vim: fileencoding=utf-8

require 'bcdice'
require 'bcdice/game_system'

require 'rgrb/plugin_base/generator'
require 'rgrb/plugin/bcdice/constants'
require 'rgrb/plugin/bcdice/errors'

module RGRB
  module Plugin
    # BCDice のラッパープラグイン
    module Bcdice
      # BCDice の呼び出し結果
      BcdiceResult = Struct.new(:message, :game_name)

      # Bcdice の出力テキスト生成器
      class Generator
        include PluginBase::Generator

        # プラグインがアダプタによって読み込まれた際の設定
        #
        # アダプタによってジェネレータが用意されたとき
        # BCDiceのバージョン情報をログに出力する。
        def configure(*)
          super

          logger.info(bcdice_version)

          self
        end

        # BCDice でダイスを振った結果を返す
        # @param [String] command ダイスコマンド
        # @param [String] specified_game_type 指定されたゲームタイプ
        # @return [BcdiceResult]
        # @raise [DiceBotNotFound] ダイスボットが見つからなかった場合
        # @raise [InvalidCommandError] 無効なコマンドが指定された場合
        def bcdice(command, specified_game_type = nil)
          # アダプターは通常、常に引数を2つ与えてこのメソッドを呼ぶ
          # そのため、デフォルト引数値では game_type を設定できない
          game_type = specified_game_type || 'DiceBot'
          # ダイスボットを探す
          dice_bot = BCDice.game_system_class(game_type)
          # ダイスボットが見つからなかった場合は中断する
          raise DiceBotNotFound, game_type unless dice_bot

          result = dice_bot.eval(command)
          # 結果が返ってこなかった場合は中断する
          raise InvalidCommandError.new(command, dice_bot) unless result

          # 結果を返す
          BcdiceResult.new(
            result.text,
            dice_bot::NAME
          )
        end

        # git submodule で組み込んでいる BCDice のバージョンを返す
        # @return [String]
        def bcdice_version
          "BCDice Version: #{BCDice::VERSION}"
        end
      end
    end
  end
end
