# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # ダイスロールを行うプラグイン
    #
    # メルセンヌ・ツイスタを用いて均一な乱数を生成します。
    module Detatoko
      # DiceRoll の出力テキスト生成器
      class Generator
        def initialize
          @random = Random.new
        end

        # 基本的なダイスロールの結果を返す
        # @param [Fixnum] n_dice ダイスの個数
        # @param [Fixnum] max ダイスの最大値
        # @return [String]
        def basic_dice(n_dice, max)
          if n_dice > 100
            "#{n_dice}d#{max}: ダイスが机から落ちてしまいましたの☆"
          else
            basic_dice_message(dice_roll(n_dice, max))
          end
        end

        def skill_decision(skill_level, solid = 0)
          header = "[detatoko] Skill-Level = #{skill_level} -> "

          case skill_level
          when 0
            result = dice_roll(3, 6)
            values = result[:values].sort.shift(2)
          when 1
            result = dice_roll(2, 6)
            values = result[:values]
          when 2..30
            result = dice_roll(skill_level + 1 , 6)
            values = result[:values].sort.pop(2)
          else
            return header + "ダイスが机から落ちてしまいましたの☆"
          end
          
          if solid == 0
            header + "#{result[:values]} = #{values.reduce(0, :+)}"
          else
            header + "#{result[:values]} + #{solid} " \
              "= #{values.reduce(0, :+) + solid}"
          end
        end

        # ダイスロールの結果を返す
        # @param [Fixnum] n_dice ダイスの個数
        # @param [Fixnum] max ダイスの最大値
        # @return [Hash]
        def dice_roll(n_dice, max)
          values = Array.new(n_dice) { @random.rand(1..max) }

          {
            n_dice: n_dice,
            max: max,
            values: values,
            sum: values.reduce(0, :+)
          }
        end
        private :dice_roll

        # 基本的なダイスロールのメッセージを返す
        # @param [Hash] result ダイスロール結果
        # @option result [Fixnum] :n_dice ダイスの個数
        # @option result [Fixnum] :max ダイスの最大値
        # @option result [Array<Fixnum>] :values ダイスの出目の配列
        # @option result [Fixnum] :sum ダイスの出目の合計
        # @return [String]
        def basic_dice_message(result)
          "#{result[:n_dice]}d#{result[:max]} = " \
            "#{result[:values]} = #{result[:sum]}"
        end
        private :basic_dice_message
      end
    end
  end
end
