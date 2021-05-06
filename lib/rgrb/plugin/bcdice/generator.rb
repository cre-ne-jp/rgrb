# vim: fileencoding=utf-8
# frozen_string_literal: true

require 'cinch/formatting'

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
      # @!attribute message
      #   @return [String] 結果のメッセージ
      # @!attribute game_name
      #   @return [String] ゲームシステム名
      BcdiceResult = Struct.new(:message, :game_name)

      # ゲームシステム検索結果
      # @!attribute message
      #   @return [String] 結果のメッセージ
      # @!attribute game_systems
      #   @return [Array<BCDice::Base>] 該当するゲームシステムの配列
      GameSystemSearchResult = Struct.new(:message, :game_systems)

      # ゲームシステム検索結果のフォーマッタを格納するモジュール
      module GameSystemListFormatter
        # プレーンテキストで出力するフォーマッタ
        PLAIN_TEXT = ->(criterion, keywords, game_systems) {
          keywords_text = keywords.join(' ')
          header = "BCDice ゲームシステム検索結果 (#{criterion}: #{keywords_text})"

          if game_systems.empty?
            "#{header}: 見つかりませんでした"
          else
            body = game_systems
                   .map { |c| "#{c::ID} (#{c::NAME})" }
                   .join(', ')

            "#{header}: #{body}"
          end
        }

        # mIRC制御文字を含むIRCメッセージを出力するフォーマッタ
        IRC_MESSAGE = ->(criterion, keywords, game_systems) {
          keywords_text = keywords
                          .map { |k| Cinch::Formatting.format(:underline, k) }
                          .join(' ')
          header = "BCDice ゲームシステム検索結果 (#{criterion}: #{keywords_text})"

          if game_systems.empty?
            "#{header}: 見つかりませんでした"
          else
            body = game_systems
                   .map { |c| "#{Cinch::Formatting.format(:bold, c::ID)} (#{c::NAME})" }
                   .join(', ')

            "#{header}: #{body}"
          end
        }

        # Markdownで出力するフォーマッタ
        MARKDOWN = ->(criterion, keywords, game_systems) {
          escaped_criterion = escape_markdown_chars(criterion)

          keywords_text = keywords
                          .map { |k| "*#{escape_markdown_chars(k)}*" }
                          .join(' ')

          header = "**BCDice ゲームシステム検索結果 " \
                   "(#{escaped_criterion}: #{keywords_text})**"

          if game_systems.empty?
            "#{header}\n見つかりませんでした"
          else
            body_lines = game_systems.map { |c|
              escaped_id = escape_markdown_chars(c::ID)
              escaped_name = escape_markdown_chars(c::NAME)

              "* #{escaped_id} (#{escaped_name})"
            }

            ([header] + body_lines).join("\n")
          end
        }

        module_function

        # Markdownの特殊文字をエスケープする
        # @param [String] s
        # @return [String]
        # @see https://www.markdownguide.org/basic-syntax/#escaping-characters
        def escape_markdown_chars(s)
          s.gsub(/[-\\`*_{}\[\]<>()#+.!|]/) { "\\#{Regexp.last_match(0)}" }
        end
      end

      # Bcdice の出力テキスト生成器
      class Generator
        include PluginBase::Generator

        def initialize
          @game_systems = BCDice.all_game_systems.sort_by { |c| c::ID }
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
        # @param [Proc] formatter 検索結果のフォーマッタ
        # @return [GameSystemSearchResult] 検索結果
        def bcdice_search_id(keyword, formatter = GameSystemListFormatter::PLAIN_TEXT)
          found_systems = @game_systems.select { |c|
            c::ID.downcase.include?(keyword.downcase)
          }

          message = formatter['ID', [keyword], found_systems]

          GameSystemSearchResult.new(message, found_systems)
        end

        # BCDiceのゲームシステムを名称で探す
        # @param [String] keywords_text キーワードのテキスト（空白区切り）
        # @param [Proc] formatter 検索結果のフォーマッタ
        # @return [GameSystemSearchResult] 検索結果
        def bcdice_search_name(keywords_text, formatter = GameSystemListFormatter::PLAIN_TEXT)
          keywords = keywords_text.split(/[\s　]+/).reject(&:empty?)
          found_systems = keywords.reduce(@game_systems) { |acc, k|
            selected = acc.select { |c| c::NAME.downcase.include?(k.downcase) }

            if selected.empty?
              break selected
            else
              selected
            end
          }

          message = formatter['名称', keywords, found_systems]

          GameSystemSearchResult.new(message, found_systems)
        end
      end
    end
  end
end
