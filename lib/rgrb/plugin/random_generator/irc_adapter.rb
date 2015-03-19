# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/generator'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/private_table'
require 'rgrb/plugin/random_generator/circular_reference'

module RGRB
  module Plugin
    module RandomGenerator
      # RandomGenerator の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'RandomGenerator')
        match(/rg#{SPACES_RE}#{TABLES_RE}/o, method: :rg)
        match(/rg-desc#{SPACES_RE}#{TABLES_RE}/o, method: :desc)
        match(/rg-info#{SPACES_RE}#{TABLES_RE}/o, method: :info)

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
              rescue TableNotFound => not_found_error
                ": 「#{not_found_error.table}」なんて表は見つからないのですわっ。"
              rescue PrivateTable => private_table_error
                ": 表「#{private_table_error.table}」からは引けませんわっ。"
              rescue CircularReference => circular_ref_error
                ": 表「#{circular_ref_error.table}」で循環参照が起こりました。" \
                  '#cre でご報告ください。'
              end
            m.target.send(header + body, true)

            sleep(1)
          end
        end

        def desc(m, tables_str)
          header = "rg-desc"

          tables_str.split(' ').each do |table|
            body =
              begin
                "<#{table}>: #{@generator.desc(table)} "
              rescue TableNotFound => not_found
                ": 「#{not_found.table}」なんて表は見つからないのですわっ。"
              end
            m.target.send(header + body, true)

            sleep(1)
          end
        end

        def info(m, tables_str)
          header = "rg-info"

          tables_str.split(' ').each do |table|
            body =
              begin
                "<#{table}>: #{@generator.info(table)} "
              rescue TableNotFound => not_found
                ": 「#{not_found.table}」なんて表は見つからないのですわっ。"
              end
            m.target.send(header + body, true)

            sleep(1)
          end
        end
      end
    end
  end
end
