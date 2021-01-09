# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Bcdice
      # ダイスボットが見つからないことを示すエラー
      class DiceBotNotFound < StandardError
        # @return [String] ゲームタイプ
        attr_reader :game_type

        # エラーを初期化する
        # @param [String] game_type ゲームタイプ
        def initialize(game_type)
          super("ゲームシステム「#{game_type}」は見つかりませんでした")

          @game_type = game_type
        end
      end

      # 無効なコマンドエラー
      class InvalidCommandError < StandardError
        # @return [String] 指定されたコマンド
        attr_reader :command
        # @return [String] ゲームシステム名
        attr_reader :game_name

        # エラーを初期化する
        # @param [String] command 指定されたコマンド
        # @param [DiceBot] dice_bot ダイスボット
        def initialize(command, dice_bot)
          super("コマンド「#{command}」は無効です")

          @command = command
          @game_name = dice_bot::NAME
        end
      end
    end
  end
end
