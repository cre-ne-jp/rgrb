# vim: fileencoding=utf-8

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/dice_roll/dice_roll_result'

require 'gdbm'
require 'json'

module RGRB
  module Plugin
    # ダイスロールを行うプラグイン
    #
    # メルセンヌ・ツイスタを用いて均一な乱数を生成します。
    module DiceRoll
      # DiceRoll の出力テキスト生成器
      class Generator
        include ConfigurableGenerator
        EXCESS_DICE_MESSAGE = "ダイスが机から落ちてしまいましたの☆"

        def initialize
          super
          @random = Random.new
          @mutex_secret_dice = Mutex.new

          @db_dir = "#{@data_path}/#{@config_id}"
          # ToDo: ボット起動時のインスタンス化されるタイミングでは、
          # @data_path, @config_id が初期化されていない(nil になっている)
          #prepare_db_dir

          @db_secret_dice = "#{@db_dir}/secret_dice"
        end

        # 基本的なダイスロールの結果を返す
        # @param [Integer] rolls ダイスの個数
        # @param [Integer] sides ダイスの最大値
        # @return [String]
        def basic_dice(rolls, sides)
          if rolls > 100
            "#{rolls}d#{sides}: #{EXCESS_DICE_MESSAGE}"
          else
            dice_roll(rolls, sides).dice_roll_format
          end
        end

        # basic_dice の日本語ダイス用ラッパー
        def basic_dice_ja(rolls_ja, sides_ja)
          basic_dice(ja_to_i(rolls_ja), ja_to_i(sides_ja))
        end

        # dXX のようなダイスロールの結果を返す
        # @param [String] rolls ダイスの面数と数
        # @return [String]
        def dxx_dice(rolls)
          if rolls.size > 20
            "d#{rolls}: #{EXCESS_DICE_MESSAGE}"
          else
            values = dxx_roll(rolls)
            "d#{rolls} = [#{values.join(',')}] = #{values.join('')}"
          end
        end

        # dxx_dice の日本語ダイス用ラッパー
        def dxx_dice_ja(rolls_ja)
          dxx_dice("#{ja_to_i(rolls_ja)}")
        end

        # シークレットロールの結果をデータベースに保存する
        # @param [String] target ダイスコマンド実行元(チャンネル名・ニックネーム)
        # @param [String] message ダイスロール実行結果
        # @return [void]
        def save_secret_roll(target, message)
          @db_secret_dice = "#{@data_path}/#{@config_id}/secret_dice"
          @mutex_secret_dice.synchronize do
            GDBM.open(@db_secret_dice) do |db|
              store = db.has_key?(target) ? JSON.parse(db[target]) : []
              store << message
              db[target] = JSON.generate(store)
            end
          end
        end

        # @param [String] target
        # @return [Array, nil]
        def open_dice(target)
          @db_secret_dice = "#{@data_path}/#{@config_id}/secret_dice"

          @mutex_secret_dice.synchronize do
            GDBM.open(@db_secret_dice) do |db|
              if db.has_key?(target)
                JSON.parse(db.delete(target))
              end
            end
          end
        end

        # ダイスロールの結果を返す
        # @param [Integer] rolls ダイスの個数
        # @param [Integer] sides ダイスの最大値
        # @return [DiceRollResult]
        def dice_roll(rolls, sides)
          values = Array.new(rolls) { @random.rand(1..sides) }
          DiceRollResult.new(rolls, sides, values)
        end

        # dXX ロールの結果を返す
        # @param [String] rolls ダイスの面数と数
        # @return [Array<Integer>]
        def dxx_roll(rolls)
          values = []
          rolls.each_char { |max| values << @random.rand(1..max.to_i) }
          values
        end

        # 日本語ダイスコマンドを数字に変換する
        # @param [String] japanese 日本語(ア段)
        # @return [String]
        def ja_to_i(japanese)
          japanese.tr('あかさたなはまやらわ', '1234567890').to_i
        end

        # データベースディレクトリを準備する
        # @return [void]
        def prepare_db_dir
          unless FileTest.exist?(@db_dir)
            # 存在しなければ、ディレクトリを作成する
            Dir.mkdir(@db_dir)
          else
            unless FileTest.directory?(@db_dir)
              # ディレクトリ以外のファイルが存在したらエラー
              raise RuntimeError
            end
          end
        end
      end
    end
  end
end
