# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/generator'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/circular_reference'

module RGRB
  module Plugin
    module RandomGenerator
      # RandomGenerator の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'RandomGenerator')
        match(/rg[ 　]+(#{TABLE_RE}(?: +#{TABLE_RE})*)/o, method: :rg)

        def initialize(*args)
          super

          prepare_generator
        end

        # NOTICE でジェネレート結果を返す
        # @return [void]
        def rg(m, tables_str)
          header = "rg[#{m.user.nick}]"

          tables_str.split(' ').each do |table|
            body =
              begin
                "<#{table}>: #{@generator.rg(table)} ですわ☆"
              rescue TableNotFound => not_found
                ": 「#{not_found.table}」なんて表は見つからないのですわっ。"
              rescue CircularReference => circular_reference
                ": 表「#{circular_reference.table}」で循環参照が起こりました。" \
                  '#cre でご報告ください。'
              end
            m.target.send(header + body, true)

            sleep(1)
          end
        end
      end
    end
  end
end
