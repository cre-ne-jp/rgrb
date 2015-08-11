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
                body = @generator.table_random(table)
                name_ja = @generator.table_name_ja(table)
              rescue TableNotFound => not_found_error
                ": #{table_not_found_message(not_found_error)}"
              end
              message = "#{@header}[#{m.user.nick}]<#{name_ja}>: #{body}"

              m.target.send(message, true)
              log_notice(m.target, message)

              sleep(1)
            end
          end

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
