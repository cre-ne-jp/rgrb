# vim: fileencoding=utf-8
# frozen_string_literal: true

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

        def initialize
          sorted_game_systems = BCDice.all_game_systems.sort_by { |c| c::ID }
          @game_system_text_pairs = sorted_game_systems.map { |c|
            [c, "#{c::ID} (#{c::NAME})"]
          }
        end

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

        # BCDice公式サイトのゲームシステム一覧のURLを返す
        # @return [String]
        def bcdice_systems
          "BCDice ゲームシステム一覧 https://bcdice.org/systems/"
        end

        # BCDiceのゲームシステムをIDで探す
        # @param [String] keyword キーワード
        # @return [String] 検索結果
        def bcdice_search_id(keyword)
          header = "BCDice ゲームシステム検索結果 (ID: #{keyword})"

          found_systems = @game_system_text_pairs.select { |c, _|
            c::ID.downcase.include?(keyword.downcase)
          }

          if found_systems.empty?
            "#{header}: 見つかりませんでした"
          else
            body = found_systems.map { |_, t| t }.join(', ')
            "#{header}: #{body}"
          end
        end
      end
    end
  end
end
