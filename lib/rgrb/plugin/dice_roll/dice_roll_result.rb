# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module DiceRoll
      class DiceRollResult
        # サイコロを振った回数
        # @return [Integer]
        attr_reader :rolls
        # サイコロの面数
        # @return [Integer]
        attr_reader :sides
        # 出目
        # @return [Array<Integer>]
        attr_reader :values
        # 出目の合計
        # @return [Integer]
        attr_reader :sum

        # 新しい DiceRollResult インスタンスを返す
        # @return [DiceRollResult]
        def initialize(rolls, sides, values)
          @rolls = rolls
          @sides = sides
          @values = values.freeze

          @sum = values.reduce(0, :+)
        end

        def dice_roll_format
          "#{@rolls}d#{@sides} = [#{@values.join(',')}] = #{@sum}"
        end

        def sw2_dll_format
          "[#{@values.join(',')}:#{@sum}]"
        end

        def bcdice_format
          "#{@sum}[#{@values.join(',')}]"
        end
      end
    end
  end
end
