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
          header = "スキルレベル = #{skill_level} -> "

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

        # 烙印を得る
        def stigma(type)
          stigma = get_stigma
          case stigma[:number].size
          when 1
            "#{stigma[:dice][0]} -> " \
              "#{stigma_text(type, stigma[:number][0])}"
          when 2
            "#{stigma[:dice][0]}#{stigma[:dice][1]} -> "
              "#{stigma_text(type, stigma[:number][0])} と " \
              "#{stigma_text(type, stigma[:number][1])}"
          end
        end

        def get_stigma()
          stigma_number = []
          dice = []
          time = 1
          second = false

#          roll = [2,6,5]
          while time > 0
            d = dice_roll(2, 6)
            result = d[:sum]
#            result = roll.shift
            if result == 2
              if second
                stigma_number.push(12)
              else
                second = true
                time += 2
              end
            else
              stigma_number.push(result)
            end
            time -= 1
            dice << d[:values]
          end

          stigma_number.sort!
          stigma_number = 
            if stigma_number.size == 2 and stigma_number[1] == 12
              [stigma_number[0]]
            else
              stigma_number
            end
          { :dice => dice, :number => stigma_number }
        end

        def stigma_text(type, number)
          case type
          when 'v'
            stigmas = [
              '痛手', '流血', '衰弱', '苦悶', '衝撃',
              '疲労', '怒号', '負傷', '軽傷', 'なし'
                          ]
          when 'm'
            stigmas = [
              '絶望', '号泣', '後悔', '恐怖', '葛藤',
              '憎悪', '呆然', '迷い', '悪夢', 'なし'
            ]
          end
          "#{number}:【#{stigmas[number - 3]}】"
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
