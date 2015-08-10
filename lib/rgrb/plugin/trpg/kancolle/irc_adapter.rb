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
          # @return [void]
          def table_random(m, table)
            header = "#{@header}[#{m.user.nick}]: "
            m.target.send(header + @generator.table_random(table), true)
          end
        end
      end
    end
  end
end
