# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # システム別専用プラグイン「でたとこサーガ」
    module Detatoko
      # Detatoko の出力テキスト生成器
      class Generator
        def initialize
          @random = Random.new
        end

        # スキルランクから判定値を算出します
        # @param [Fixnum] skill_rank スキルランク
        # @param [Fixnum] solid 追加ダメージ(固定値)
        # @return [String]
        def skill_decision(skill_rank, solid = 0)
          header = "スキルランク = #{skill_rank} -> "

          case skill_rank
          when 0
            result = dice_roll(3, 6)
            values = result[:values].sort.shift(2)
          when 1
            result = dice_roll(2, 6)
            values = result[:values]
          when 2..30
            result = dice_roll(skill_rank + 1 , 6)
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
        # @param [String] type 体力・気力烙印のどちらか
        # @return [String]
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

        # バッドエンド表を振る
        def badend(type)
          result = dice_roll(2, 6)
          "#{result[:values]} -> #{badend_text(type, result[:sum])}"
        end

        # ダイスを振り獲得する烙印を決める
        # @return [Hash]
        #   @option [Array] :dice (1dの)出目
        #   @option [Array] :stigma_number 烙印に対応する出目
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
        private :get_stigma

        # 出目から対応する烙印を決定する
        # @param [String] type 体力・気力のどちらか
        # @param [Fixnum] number ダイスの出目
        # @return [String]
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
        private :stigma_text

        # 出目から対応するバッドエンドを決定する
        # @param [String] type 体力・気力のどちらか
        # @param [Fixnum] number ダイスの出目
        # @return [String]
        def badend_text(type, number)
          case type
          when 'v'
            badends = [
              '死亡', '命乞', '忘却', '悲劇', '暴走', '転落', 
              '虜囚', '逃走', '重症', '気絶', 'なし'
            ]
          when 'm'
            badends = [
              '自害', '堕落', '隷属', '裏切', '暴走', '呪い', 
              '虜囚', '逃走', '放心', '気絶', 'なし'
            ]
          end
          "#{number}:【#{badends[number - 2]}】"
        end
        private :badend_text

        # ダイスロールの結果を返す
        # @param [Fixnum] n_dice ダイスの個数
        # @param [Fixnum] max ダイスの最大値
        # @return [Hash]
        #   @option [Fixnum] :n_dice ダイスの個数
        #   @option [Fixnum] :max ダイスの最大値
        #   @option [Array<Fixnum>] :values ダイスの出目の配列
        #   @option [Fixnum] :sum ダイスの出目の合計
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
      end
    end
  end
end
