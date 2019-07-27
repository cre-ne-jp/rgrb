# vim: fileencoding=utf-8

require 'd1lcs'
require 'rgrb/plugin_base/generator'
require 'rgrb/plugin/dice_roll/generator'
require 'rgrb/plugin/trpg/detatoko/gamedatas'

module RGRB
  module Plugin
    module Trpg
      # システム別専用プラグイン「でたとこサーガ」
      module Detatoko
        # Detatoko の出力テキスト生成器
        class Generator
          include PluginBase::Generator

          def initialize(*)
            super

            @random = Random.new
            @dice_roll_generator = DiceRoll::Generator.new
            @d1lcs_title_line = D1lcs.title_line
          end

          # スキルランクから判定値を算出します
          # @param [Integer] skill_rank スキルランク
          # @param [String] calc 計算記号
          # @param [Integer] solid 追加ダメージ(固定値)
          # @param [Integer] flag フラグ
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
          # @param [Symbol] type 体力・気力烙印のどちらか
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
          # @param [Symbol] type 体力・気力のどちらか
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
          # @param [Symbol] type 通常の立場表か、悪への立場表か
          # @option :normal 通常の立場表
          # @option :dark   悪へのラスボス立場表
          # @return [String]
          def ground(type = :normal)
            result = @dice_roll_generator.dice_roll(2, 6)
            number = result.sum

            "#{result.sw2_dll_format} -> " \
              "#{number}: 【#{GROUNDS[type][number - 2]}】"
          end

          # クラスを1つ選ぶ
          # @return [String]
          def character_class
            result = CLASSES.to_a.sample
            "%02d -> #{result[0]}" % result[1]
          end

          # ポジションを1つ選ぶ
          # @param [Symbol] type 用途
          # @option type :pc   PC のポジション
          # @option type :npc  敵 NPC のポジション
          # @option type :dark 悪のポジション
          # @return [String]
          def position(type)
            POSITIONS[type].sample
          end

          # 【好きなもの・趣味】／【苦手なもの・弱点】表を引く
          # @return [String]
          def like_things
            value = @dice_roll_generator.dxx_roll('66')
            thing = LIKE_THINGS[value[0] - 1][value[1] - 1]
            if thing === '特定の環境'
              value << @random.rand(1..6)
              thing = "#{LIKE_THINGS[6][value[2] - 1]} (#{thing})"
            else
              things = thing.split('／')
              thing = "#{things.sample} (#{thing})" if things.size > 1
            end

            "[#{value.join(',')}] -> #{value.join('')} : #{thing}"
          end

          # ラスボスチャート・クエストチャートを引く
          # @param [Symbol] type ラスボスか、クエストか
          # @option :lastboss ラスボスチャート
          # @option :quest クエストチャート
          # @return [String]
          def chart(type)
            value = @dice_roll_generator.dxx_roll('66')
            result = CHARTS[type][(value[0] - 1) * 6 + value[1] - 1]
            "[#{value.join(',')}] -> #{value.join('')} : #{result}"
          end

          # 1行キャラシを出力する
          # @param [Array<String>] ids 対象のキャラシID
          # @return [Hash]
          # @option return [Array<String>] :lcs キャラクターシート
          # @option return [Array<String>] :errors 発生したエラー
          def lcs(ids)
            result = { :lcs => [nil], :errors => [] }
            ids.each { |id|
              case id
              when 'title'
                result[:lcs][0] = @d1lcs_title_line
              else
                cs = D1lcs::Element.new(id)
                if(cs.error != nil)
                  result[:errors] << cs.error
                else
                  result[:lcs] << cs.chara_sheet_line
                end
              end
            }

            result[:lcs].compact!

            result
          end

          private

          # ダイスを振り獲得する烙印を決める
          # @return [Array<Array>]
          def get_stigma
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

          # 出目から対応する烙印を決定する
          # @param [Symbol] type 体力・気力のどちらか
          # @param [Integer] number ダイスの出目
          # @return [String]
          def stigma_text(type, number)
            STIGMAS[type][number - 3] &&
              "#{number}: 【#{STIGMAS[type][number - 3]}】"
          end

          # 出目から対応するバッドエンドを決定する
          # @param [Symbol] type 体力・気力のどちらか
          # @param [Integer] number ダイスの出目
          # @return [String]
          def badend_text(type, number)
            "#{number}: 【#{BADENDS[type][number - 2]}】"
          end

          # 文字列をスタンスの系統に分ける
          # @param [String] uses 元の文字列
          # @return [Array<String>] 使用するスタンス系統のリスト
          def what_stance_list(uses)
            return STANCES.keys if uses.empty?

            separators = /[\+＋・]/
            STANCES.keys & uses.split(separators)
          end

          # 指定された系統のスタンスをランダムに選ぶ
          # @param [String] type スタンス系統
          # @return [String]
          def stance_select(type)
            rand = @random.rand(6)
            "#{rand + 1}:【#{STANCES[type][rand]}】"
          end
        end
      end
    end
  end
end
