# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/trpg/kancolle/generator'
require 'rgrb/plugin/trpg/kancolle/constants'

module RGRB
  module Plugin
    module Trpg
      module Kancolle
        # Kancolle の IRC アダプター
        class IrcAdapter
          include Cinch::Plugin
          include ConfigurableAdapter

          set(plugin_name: 'Trpg::Kancolle')
          self.prefix = '.kc'
          match(/m/i, method: :kanmusu)
          match(/mr#{SPACES_RE}#{KANMUSU_RE}/io, method: :kanmusu_reaction)
          match(/t#{SPACES_RE}#{TABLES_RE}/io, method: :table_random)

          match(/娘/i, method: :kanmusu_ja, :prefix => "。艦")
          match(/リアクション#{SPACES_RE}(.*)/io, method: :kanmusu_reaction_ja, :prefix => "。艦")
          match(/表#{SPACES_RE}(.*)/io, method: :table_random_ja, :prefix => "。艦")

          def initialize(*args)
            super
            prepare_generator

            @header = "艦これRPG "
          end

          # 艦娘から一人選ぶ
          # @return [void]
          def kanmusu(m)
            header = "#{@header}[#{m.user.nick}]: "
            m.target.send(header + @generator.kanmusu, true)
          end
          
          # 艦娘のリアクション表を振る
          # @return [void]
          def kanmusu_reaction(m, kanmusu)
            header = "#{@header}[#{m.user.nick}]: "
            m.target.send(header + @generator.kanmusu_reaction(kanmusu), true)
          end

          # その他のイベント表などを振る
          # @param [Cinch::Message] m メッセージ
          # @param [String] tables_str 表のリスト
          # @return [void]
          def table_random(m, tables_str)
            tables_str.split(' ').each do |table|
              begin
                body = "<#{@generator.table_name_ja(table)}>" \
                  ": #{@generator.table_random(table)}"
              rescue TableNotFound => not_found_error
                body = ": #{table_not_found_message(not_found_error)}"
              end
              message = "#{@header}[#{m.user.nick}]#{body}"

              m.target.send(message, true)
              log_notice(m.target, message)

              sleep(1)
            end
          end

          def kanmusu_ja(m)
          end

          def kanmusu_reaction_ja(m, kanmusu)
          end

          # 日本語で決定表名を書かれたときその表を振る
          # table_random の日本語コマンド用ラッパー
          # @param [Cinch::Message] m メッセージ
          # @param [String] tables_str_ja 決定表名のリスト
          # @return [void]
          def table_random_ja(m, tables_str_ja)
            tables = []
            tables_str_ja.split(SPACES_RE).each do |table|
              tables << @generator.table_name_en(table.gsub(/表$/, ''))
            end

            tables_str = tables.join(' ')
            return if tables_str == ''

            table_random(m, tables_str)
          end

          # 表が見つからなかったときのメッセージを返す
          # @param [TableNotFound] error エラー
          # @return [String]
          def table_not_found_message(error)
            "「#{error.table}」なんて表は見つからないのですわっ。"
          end
          private :table_not_found_message

          # NOTICE 送信をログに残す
          # @param [Cinch::Target] target 対象
          # @param [String] message メッセージ
          # @return [void]
          def log_notice(target, message)
            log(
              "<NOTICE to #{target}> #{message.inspect}",
              :outgoing, :info
            )
          end
          private :log_notice
        end
      end
    end
  end
end
