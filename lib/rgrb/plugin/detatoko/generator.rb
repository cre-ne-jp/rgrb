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
          response = {:dice => '', :stigma => [] }

          stigma.each { |values|
            response[:dice] << to_sw2dll(values)
            response[:stigma] << stigma_text(type, values.reduce(0, :+))
          }
          response[:stigma].delete(nil)
          response[:stigma] << 'なし' if response[:stigma].empty?

          message = "#{response[:dice]} -> "
          response[:stigma].each { |stigma_name|
            message << "#{stigma_name} と "
          }
          3.times { message.chop! }
          message
        end

        # バッドエンド表を振る
        # @param [String] type 体力・気力のどちらか
        def badend(type)
          result = dice_roll(2, 6)
          "#{result[:values]} -> #{badend_text(type, result[:sum])}"
        end

        # ダイスを振り獲得する烙印を決める
        # @return [Array<Array>]
        def get_stigma()
          stigma_number = []
          time = 1
          second = false

          while time > 0
            time -= 1
            dice = dice_roll(2, 6)
            if dice[:sum] == 2 and !second
                second = true
                time += 2
            end
            stigma_number << dice[:values]
          end

          stigma_number
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
              '疲労', '怒号', '負傷', '軽傷', nil
            ]
          when 'm'
            stigmas = [
              '絶望', '号泣', '後悔', '恐怖', '葛藤',
              '憎悪', '呆然', '迷い', '悪夢', nil
            ]
          end

          stigmas[number - 3] && "#{number}:【#{stigmas[number - 3]}】"
        end
        private :stigma_text

        # 配列をSW2_DLLの出力と同じ形式に変換する
        # @param [Array] values 1d6の出目2つ
        # @return [String]
        def to_sw2dll(values)
          "[#{values[0]},#{values[1]}:#{values[0] + values[1]}]"
        end
        private :to_sw2dll

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
