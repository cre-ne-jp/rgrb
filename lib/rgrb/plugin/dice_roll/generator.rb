# vim: fileencoding=utf-8

require 'rgrb/plugin/dice_roll/dice_roll_result'

module RGRB
  module Plugin
    # ダイスロールを行うプラグイン
    #
    # メルセンヌ・ツイスタを用いて均一な乱数を生成します。
    module DiceRoll
      # DiceRoll の出力テキスト生成器
      class Generator
        TOO_MANY_DICES = "ダイスが机から落ちてしまいましたの☆"
        
        def initialize
          @random = Random.new
        end

        # 基本的なダイスロールの結果を返す
        # @param [Fixnum] rolls ダイスの個数
        # @param [Fixnum] sides ダイスの最大値
        # @return [String]
        def basic_dice(rolls, sides)
          if rolls > 100
            "#{rolls}d#{sides}: #{TOO_MANY_DICES}"
          else
            dice_roll(rolls, sides).dice_roll_format
          end
        end

        # dXX のようなダイスロールの結果を返す
        # @param [String] rolls ダイスの面数と数
        # @return [String]
        def dxx_dice(rolls)
          if rolls.size > 20
            "d#{rolls}: #{TOO_MANY_DICES}"
          else
            dxx_roll(rolls)
          end
        end

        # ダイスロールの結果を返す
        # @param [Fixnum] rolls ダイスの個数
        # @param [Fixnum] sides ダイスの最大値
        # @return [DiceRollResult]
        def dice_roll(rolls, sides)
          values = Array.new(rolls) { @random.rand(1..sides) }
          DiceRollResult.new(rolls, sides, values)
        end

        # dXX ロールの結果を返す
        # @param [String] rolls ダイスの面数と数
        # @return [String]
        def dxx_roll(rolls)
          values = []
          rolls.each_char { |max| values << @random.rand(1..max.to_i) }
          "d#{rolls} = [#{values.join(',')}] = #{values.join('')}"
        end
      end
    end
  end
end
