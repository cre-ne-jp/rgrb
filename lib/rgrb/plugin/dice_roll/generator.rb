# vim: fileencoding=utf-8

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/dice_roll/dice_roll_result'

require 'gdbm'

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

          @db_name = "#{@data_path}/#{@config_id}"
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

        # @param [String] target
        # @param [String] message
        def save_secret_roll(target, message)
          @db_name = "#{@data_path}/#{@config_id}"
          GDBM.open(@db_name) do |db|
            store = db.has_key?('secret_dice') ? JSON.parse(db['secret_dice']) : {}
            store.has_key?(target) ? store[target] << message : store[target] = [message]
            db['secret_dice'] = JSON.generate(store)
          end
        end

        # @param [String] target
        # @return [Array]
        def open_dice(target)
          @db_name = "#{@data_path}/#{@config_id}"
          result = []

          GDBM.open(@db_name) do |db|
            store = db.has_key?('secret_dice') ? JSON.parse(db['secret_dice']) : {}
            result = store[target]
            store[target] = nil
            db['secret_dice'] = JSON.generate(store.compact)
          end

          result.nil? ? [] : result
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

        def ja_to_i(japanese)
          japanese.tr('あかさたなはまやらわ', '1234567890').to_i
        end
      end
    end
  end
end
