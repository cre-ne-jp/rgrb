# vim: fileencoding=utf-8

require 'rgrb/plugin_base/discord_adapter'
require 'rgrb/plugin/trpg/detatoko/generator'
require 'rgrb/plugin/trpg/detatoko/constants'

module RGRB
  module Plugin
    module Trpg
      module Detatoko
        # Detatoko の Discord アダプター
        class DiscordAdapter
          include PluginBase::DiscordAdapter

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

          match(/lt/i, method: :like_things)

          match(/(lb|q)c/i, method: :chart)

          match(/cs #{LCSIDS_RE}/io, method: :lcs)

          match(/す([あかさたなはまやらわ]+)/i, method: :skill_decision_ja, :prefix => prefix_ja)
          match(/(体|気)力烙印/i, method: :stigma, :prefix => prefix_ja)
          match(/(体|気)力バッドエンド/i, method: :badend, :prefix => prefix_ja)
          match(/スタンス[\s　]+(#{STANCE_RE})/io, method: :stance, :prefix => prefix_ja)
          match(/(|悪への)ラスボス立場/i, method: :ground, :prefix => prefix_ja)
          match(/クラス/i, method: :character_class, :prefix => prefix_ja)
          match(/(|敵|悪)ポジション/i, method: :position, :prefix => prefix_ja)
          match(/((?:趣味|苦手)|(?:好き|嫌い)なもの)/i, method: :like_things, :prefix => prefix_ja)
          match(/(ラスボス|クエスト)チャート/i, method: :chart, :prefix => prefix_ja)

          def initialize(*args)
            super

            prepare_generator
            @header = "でたとこサーガ "
          end

          # スキルランクから判定値を得る
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] skill_rank スキルランク
          # @param [String] calc 判定値に四則演算を行なう場合の演算子
          # @param [String] solid 四則演算を行なう場合の計算される数
          # @param [String] flag 現在の PC のフラグ値
          # @return [void]
          def skill_decision(m, skill_rank, calc = '+', solid = 0, flag = 0)
            log_incoming(m)
            messages = @generator
              .skill_decision(skill_rank.to_i, calc, solid.to_i, flag.to_i)
            send_channel(m.channel, messages, "#{@header}[#{m.user.mention}]: ")
          end

          # skill_decision のフラグ先行コマンド用ラッパー
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] skill_rank スキルランク
          # @param [String] flag 現在の PC のフラグ値
          # @param [String] calc 判定値に四則演算を行なう場合の演算子
          # @param [String] solid 四則演算を行なう場合の計算される数
          # @return [void]
          def skill_decision_flag(m, skill_rank, flag = 0, calc = '+', solid = 0)
            log_incoming(m)
            skill_decision(m, skill_rank, calc, solid, flag)
          end

          # skill_decision の日本語コマンド
          # 日本語コマンドは四則演算はフラグ値を考慮しない
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] skill_rank_ja スキルランクの日本語形式
          # @return [void]
          def skill_decision_ja(m, skill_rank_ja)
            log_incoming(m)
            messages = @generator.skill_decision_ja(skill_rank_ja)
            send_channel(m.channel, messages, "#{@header}[#{m.user.mention}]: ")
          end

          # 烙印(p.63)を得る
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] tcode 何の烙印か
          # @return [void]
          def stigma(m, tcode)
            log_incoming(m)
            tcode = type_tr(tcode)
            header = "#{@header}[#{m.user.mention}]<#{type_conv(tcode)}力烙印>: "
            message = @generator.stigma(tcode)
            send_channel(m.channel, message, header)
          end

          # バッドエンド表(p.65)を振る
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] tcode 何のバッドエンド表か
          # @return [void]
          def badend(m, tcode)
            log_incoming(m)
            tcode = type_tr(tcode)
            header = "#{@header}[#{m.user.mention}]<#{type_conv(tcode)}力バッドエンド>: "
            message = @generator.badend(tcode)
            send_channel(m.channel, message, header)
          end

          # スタンス表から引く
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] uses 選ぶ元となるスタンス
          # @return [void]
          def stance(m, uses)
            log_incoming(m)
            header = "#{@header}[#{m.user.mention}]<スタンス表>: "
            message = @generator.stance(uses)
            send_channel(m.channel, message, header)
          end

          # ラスボス立場表を引く
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] type 何のラスボス立場表か
          # @return [void]
          def ground(m, type)
            log_incoming(m)
            insert, type = case type
            when 'lb', ''
              ['', :normal]
            when 'd', '悪への'
              ['悪への', :dark]
            end
            header = "#{@header}[#{m.user.mention}]<#{insert}ラスボス立場>: "
            message = @generator.ground(type)
            send_channel(m.channel, message, header)
          end

          # クラスを1つ選ぶ
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @return [void]
          def character_class(m)
            log_incoming(m)
            header = "#{@header}[#{m.user.mention}]<クラス>: "
            message = @generator.character_class
            send_channel(m.channel, message, header)
          end

          # ポジションを1つ選ぶ
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] type 何のポジションか
          # @return [void]
          def position(m, type)
            log_incoming(m)
            insert, type = case type
              when ''
                ['PC', :pc]
              when 'n', '敵'
                ['敵NPC', :npc]
              when 'd', '悪'
                ['悪の', :dark]
              end
            header = "#{@header}[#{m.user.mention}]<#{insert}ポジション>: "
            message = @generator.position(type)
            send_channel(m.channel, message, header)
          end

          # 【好きなもの・趣味】／【苦手なもの・弱点】表を引く
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @return [void]
          def like_things(m)
            log_incoming(m)
            header = "#{@header}[#{m.user.mention}]<趣味・弱点>: "
            message = @generator.like_things
            send_channel(m.channel, message, header)
          end

          # ラスボスチャート・クエストチャートを引く
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] type ラスボスか・クエストか
          # @return [void]
          def chart(m, type)
            log_incoming(m)

            insert, type = case type
            when 'lb', 'ラスボス'
              ['ラスボス', :lastboss]
            when 'q', 'クエスト'
              ['クエスト', :quest]
            end

            header = "#{@header}[#{m.user.mention}]<#{insert}チャート>: "
            message = @generator.chart(type)
            send_channel(m.channel, message, header)
          end

          # 1行のキャラクターシートを生成する
          # @param [Discordrb::Events::MessageEvent] m メッセージ
          # @param [String] ids_str キャラクターシートの ID (String 型)
          # @return [void]
          def lcs(m, ids_str)
            log_incoming(m)

            result = @generator.lcs(ids_str.split(' '))
            messages = []

            if(result[:errors].count != 0)
              header = "#{@header}[#{m.user.mention}]<1行キャラクターシート>: "
              messages << "#{header}#{result[:errors].count} 件のエラーが発生しました"
              messages.concat(result[:errors].map {|line| "#{header}#{line}"})
            end
            messages.concat(result[:lcs])

            send_channel(m.channel, messages)
          end

          private

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

          # コマンドでの表記を内部での体力・気力のフラグに書き換える
          # @param [String] code コマンドでの表記
          # @return [Symbol]
          def type_tr(code)
            code.tr!('tk', 'vm')
            code.tr!('sw', 'vm')
            code.tr!('体気', 'vm')
            code.to_sym
          end
        end
      end
    end
  end
end
