# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/trpg/detatoko/generator'
require 'rgrb/plugin/trpg/detatoko/constants'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module Trpg
      module Detatoko
        # Detatoko の IRC アダプター
        class IrcAdapter
          include Cinch::Plugin
          include Util::Logging

          set(plugin_name: 'Trpg::Detatoko')
          self.prefix = '.d'
          prefix_ja = '。で'

          match(/#{SR_RE}#{END_RE}/io, method: :skill_decision)
          match(/#{SR_RE}#{SOLID_RE}#{END_RE}/io, method: :skill_decision)
          match(/#{SR_RE}#{SOLID_RE}#{FLAG_RE}/io, method: :skill_decision)
          match(/#{SR_RE}#{FLAG_RE}#{END_RE}/io, method: :skill_decision_flag)
          match(/#{SR_RE}#{FLAG_RE}#{SOLID_RE}/io, method: :skill_decision_flag)

          match(/(v|m|s|w)s/i, method: :stigma)
          match(/(t|k)r/i, method: :stigma)
          
          match(/(v|m|s|w)be/i, method: :badend)
          match(/(t|k)b/i, method: :badend)
          
          match(/stance[\s　]+(#{STANCE_RE})/io, method: :stance)

          match(/(lb|d)g/i, method: :ground)

          match(/c(?:[^s]|$)/i, method: :character_class)

          match(/(|n|d)pp/i, method: :position)

          match(/cs #{LCSIDS_RE}/io, method: :lcs)

          match(/す([あかさたなはまやらわ]+)/i, method: :skill_decision_ja, :prefix => prefix_ja)
          match(/(体|気)力烙印/i, method: :stigma, :prefix => prefix_ja)
          match(/(体|気)力バッドエンド/i, method: :badend, :prefix => prefix_ja)
          match(/スタンス[\s　]+(#{STANCE_RE})/io, method: :stance, :prefix => prefix_ja)
          match(/(|悪への)ラスボス立場/i, method: :ground, :prefix => prefix_ja)
          match(/クラス/i, method: :character_class, :prefix => prefix_ja)
          match(/(|敵|悪)ポジション/i, method: :position, :prefix => prefix_ja)

          def initialize(*args)
            super

            @generator = Generator.new
            @header = "でたとこサーガ "
          end

          # スキルランクから判定値を得る
          # @param [Cinch::Message] m
          # @param [String] skill_rank スキルランク
          # @param [String] calc 判定値に四則演算を行なう場合の演算子
          # @param [String] solid 四則演算を行なう場合の計算される数
          # @param [String] flag 現在の PC のフラグ値
          # @return [void]
          def skill_decision(m, skill_rank, calc = '+', solid = 0, flag = 0)
            header = "#{@header}[#{m.user.nick}]: "
            @generator
              .skill_decision(skill_rank.to_i, calc, solid.to_i, flag.to_i)
              .each_line { |line|
                m.target.send(header + line.chomp, true)
              }
          end

          # skill_decision のフラグ先行コマンド用ラッパー
          # @param [Cinch::Message] m
          # @param [String] skill_rank スキルランク
          # @param [String] flag 現在の PC のフラグ値
          # @param [String] calc 判定値に四則演算を行なう場合の演算子
          # @param [String] solid 四則演算を行なう場合の計算される数
          # @return [void]
          def skill_decision_flag(m, skill_rank, flag = 0, calc = '+', solid = 0)
            skill_decision(m, skill_rank, calc, solid, flag)
          end

          # skill_decision の日本語コマンド
          # 日本語コマンドは四則演算はフラグ値を考慮しない
          # @param [Cinch::Message] m
          # @param [String] skill_rank_ja スキルランクの日本語形式
          # @return [void]
          def skill_decision_ja(m, skill_rank_ja)
            header = "#{@header}[#{m.user.nick}]: "
            @generator
              .skill_decision_ja(skill_rank_ja)
              .each_line { |line|
                m.target.send(header + line.chomp, true)
              }
          end

          # 烙印(p.63)を得る
          # @param [Cinch::Message] m
          # @param [String] tcode 何の烙印か
          # @return [void]
          def stigma(m, tcode)
            tcode = type_tr(tcode)
            header = "#{@header}[#{m.user.nick}]<#{type_conv(tcode)}力烙印>: "
            message = @generator.stigma(tcode)
            m.target.send(header + message, true)
          end

          # バッドエンド表(p.65)を振る
          # @param [Cinch::Message] m
          # @param [String] tcode 何のバッドエンド表か
          # @return [void]
          def badend(m, tcode)
            tcode = type_tr(tcode)
            header = "#{@header}[#{m.user.nick}]<#{type_conv(tcode)}力バッドエンド>: "
            message = @generator.badend(tcode)
            m.target.send(header + message, true)
          end

          # スタンス表から引く
          # @param [Cinch::Message] m
          # @param [String] uses 選ぶ元となるスタンス
          # @return [void]
          def stance(m, uses)
            header = "#{@header}[#{m.user.nick}]<スタンス表>: "
            message = @generator.stance(uses)
            m.target.send(header + message, true)
          end

          # ラスボス立場表を引く
          # @param [Cinch::Message] m
          # @param [String] type 何のラスボス立場表か
          # @return [void]
          def ground(m, type)
            insert, type = case type
            when 'lb', ''
              ['', :normal]
            when 'd', '悪への'
              ['悪への', :dark]
            end
            header = "#{@header}[#{m.user.nick}]<#{insert}ラスボス立場>: "
            message = @generator.ground(type)
            m.target.send(header + message, true)
          end

          # クラスを1つ選ぶ
          # @param [Cinch::Message] m
          # @return [void]
          def character_class(m)
            header = "#{@header}[#{m.user.nick}]<クラス>: "
            message = @generator.character_class
            m.target.send(header + message, true)
          end

          # ポジションを1つ選ぶ
          # @param [Cinch::Message] m
          # @param [String] type 何のポジションか
          # @return [void]
          def position(m, type)
            insert, type = case type
              when ''
                ['PC', :pc]
              when 'n', '敵'
                ['敵NPC', :npc]
              when 'd', '悪'
                ['悪の', :dark]
              end
            header = "#{@header}[#{m.user.nick}]<#{insert}ポジション>: "
            message = @generator.position(type)
            m.target.send(header + message, true)
          end

          # 1行のキャラクターシートを生成する
          # @param [Cinch::Message] m
          # @param [String] ids_str キャラクターシートの ID (String 型)
          # @return [void]
          def lcs(m, ids_str)
            log_incoming(m)

            header = "#{header}[#{m.user.nick}]<1行キャラクターシート>: "
            result = @generator.lcs(ids_str.split(' '))

            if(result[:errors].count != 0)
              message = "#{header}#{result[:errors].count} 件のエラーが発生しました"
              log_notice(m.target, message)
              m.target.send(message, true)
              result[:errors].each { |line|
                message = header + line
                log_notice(m.target, message)
                m.target.send(message, true)
                sleep(1)
              }
            end
            result[:lcs].each { |line|
              log_notice(m.target, line)
              m.target.send(line, true)
              sleep(1)
            }
          end

          # 体力・気力コードを対応する日本語に変換する
          # @param [String/Symbol] tcode 体力・気力コード
          # @return [String]
          def type_conv(tcode)
            case "#{tcode}"
            when 'v'
              '体'
            when 'm'
              '気'
            end
          end
          private :type_conv

          # コマンドでの表記を内部での体力・気力のフラグに書き換える
          # @param [String] code コマンドでの表記
          # @return [Symbol]
          def type_tr(code)
            code.tr!('tk', 'vm')
            code.tr!('sw', 'vm')
            code.tr!('体気', 'vm')
            code.to_sym
          end
          private :type_tr
        end
      end
    end
  end
end
