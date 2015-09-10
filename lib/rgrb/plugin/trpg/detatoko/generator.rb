# vim: fileencoding=utf-8

require 'rgrb/plugin/dice_roll/generator.rb'

module RGRB
  module Plugin
    module Trpg
      # システム別専用プラグイン「でたとこサーガ」
      module Detatoko
        # Detatoko の出力テキスト生成器
        class Generator

          def initialize
            @random = Random.new
            @dice_roll_generator = DiceRoll::Generator.new
          end

          # スキルランクから判定値を算出します
          # @param [Fixnum] skill_rank スキルランク
          # @param [String] calc 計算記号
          # @param [Fixnum] solid 追加ダメージ(固定値)
          # @param [Fixnum] flag フラグ
          # @return [String]
          def skill_decision(skill_rank, calc, solid, flag)
            header = "スキルランク = #{skill_rank} -> "

            case skill_rank
            when 0
              result = @dice_roll_generator.dice_roll(3, 6)
              values = result.values.sort.shift(2)
            when 1
              result = @dice_roll_generator.dice_roll(2, 6)
              values = result.values
            when 2..30
              result = @dice_roll_generator.dice_roll(skill_rank + 1 , 6)
              values = result.values.sort.pop(2)
            else
              return header + "ダイスが机から落ちてしまいましたの☆"
            end
            decision = values.reduce(0, :+)

            message = header
            message << "[#{result.values.join(',')}:#{decision}]"
            message << " #{calc} #{solid}" unless solid == 0
            message << " = "
            message << eval("#{decision.to_f} #{calc} #{solid}").ceil.to_s
            unless flag == 0
              message << " (フラグ:#{flag})"
              if decision <= flag
                message << "\n【フラグ以下】気力ダメージ -> 1d6 = "
                message << "#{@random.rand(1..6)}"
              end
            end

            message
          end

          # skill_decision の日本語コマンド用ラッパー
          # @param [String] skill_rank_ja ひらがな表現のスキルランク
          # @return [String]
          def skill_decision_ja(skill_rank_ja)
            skill_decision(@dice_roll_generator.ja_to_i(skill_rank_ja), '+', 0, 0)
          end

          # 烙印を得る
          # @param [String] type 体力・気力烙印のどちらか
          # @return [String]
          def stigma(type)
            stigma = get_stigma
            response = {:dice => '', :stigma => [] }

            stigma.each { |values|
              d = DiceRoll::DiceRollResult.new(0, 0, values)
              response[:dice] << d.sw2_dll_format
              response[:stigma] << stigma_text(type, d.sum)
            }
            response[:stigma].compact!
            response[:stigma] << 'なし' if response[:stigma].empty?

            "#{response[:dice]} -> #{response[:stigma].join(' と ')}"
          end

          # バッドエンド表を振る
          # @param [String] type 体力・気力のどちらか
          # @return [String]
          def badend(type)
            result = @dice_roll_generator.dice_roll(2, 6)
            "#{result.sw2_dll_format} -> #{badend_text(type, result.sum)}"
          end

          # スタンス表を振る
          # @param [String] uses 列挙された使用するスタンス系統
          # @return [String]
          def stance(uses)
            uses = '' if /全部/ =~ uses
            use_list = what_stance_list(uses)
            stance_type = use_list.sample
            "候補:[#{use_list.join(',')}] -> " \
              "系統:【#{stance_type}】 #{stance_select(stance_type)}"
          end

          # ラスボス立場表を振る
          # @return [String]
          def lastboss_position()
            result = @dice_roll_generator.dice_roll(2, 6)
            "#{result.sw2_dll_format} -> #{lastboss_position_text(result.sum)}"
          end

          # ダイスを振り獲得する烙印を決める
          # @return [Array<Array>]
          def get_stigma()
            stigma_number = []
            time = 1
            second = false

            while time > 0
              time -= 1
              dice = @dice_roll_generator.dice_roll(2, 6)
              stigma_number << dice.values
              if dice.sum == 2 and !second
                  second = true
                  time += 2
              end
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

          # 出目から対応するラスボス立場を決定する
          # @param [Fixnum] number ダイスの出目
          # @return [String]
          def lastboss_position_text(number)
            positions = [
              '恐怖', '破壊', '封印', '滅亡', '侵略', '暴君',
              '陰謀', '独裁', '崇拝', '犠牲', '人望'
            ]
            "#{number}: 【#{positions[number - 2]}】"
          end

          # 文字列をスタンスの系統に分ける
          # @param [String] uses 元の文字列
          # @return [Array<String>] 使用するスタンス系統のリスト
          def what_stance_list(uses)
            return STANCES.dup if uses.empty?

            separators = /[\+＋・]/
            STANCES & uses.split(separators)
          end
          private :what_stance_list

          # 指定された系統のスタンスをランダムに選ぶ
          # @param [String] type スタンス系統
          # @return [String]
          def stance_select(type)
            stance = case type
            when '敵視'
              ['邪魔', '好敵手', '標的', '使命', '異世界召喚', '討伐者']
            when '宿命'
              ['救済', '神託', 'あの人は今', '風来坊', '自己投影', '嵐の予兆']
            when '憎悪'
              ['暗い目', '悪を憎む', '劣等感', '怨念', '裏切り', '復讐']
            when '雲上'
              ['怯え', '小市民', '懊悩', '嘆願', '世捨て人', '誰それ?']
            when '従属'
              ['隷従', '呪縛', '勘違い', '弱肉強食', '居場所', '心酔']
            when '不明'
              ['野心の炎', '大いなる御方', '戯れ', '好奇心', '天秤', '超越']
            end

            rand = @random.rand(6)
            "#{rand + 1}:【#{stance[rand]}】"
          end
          private :stance_select
        end
      end
    end
  end
end
