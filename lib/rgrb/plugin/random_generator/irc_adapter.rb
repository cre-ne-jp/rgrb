# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/generator'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/private_table'

module RGRB
  module Plugin
    module RandomGenerator
      # RandomGenerator の IRC アダプター
      #
      # TODO：RGRB::Plugin::Util::Logging を利用したログ記録
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
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def rg(m, tables_str)
          log(m.raw, :incoming, :info)

          header = "rg[#{m.user.nick}]"

          tables_str.split(' ').each do |table|
            lines =
              begin
                "#{@generator.rg(table)} ですわ☆".
                  split("\n").
                  map { |line| "<#{table}>: #{line}" }
              rescue TableNotFound => not_found_error
                [": #{table_not_found_message(not_found_error)}"]
              rescue PrivateTable => private_table_error
                [": #{private_table_message(private_table_error)}"]
              end

            lines.each do |line|
              message = "#{header}#{line.chomp}"
              m.target.send(message, true)
              log_notice(m.target, message)
            end

            sleep(1)
          end
        end

        # NOTICE で表の説明を返す
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def desc(m, tables_str)
          log(m.raw, :incoming, :info)

          header = "rg-desc"

          tables_str.split(' ').each do |table|
            body =
              begin
                "<#{table}>: #{@generator.desc(table)} "
              rescue TableNotFound => not_found_error
                ": #{table_not_found_message(not_found_error)}"
              end
            message = "#{header}#{body}"

            m.target.send(message, true)
            log_notice(m.target, message)

            sleep(1)
          end
        end

        # NOTICE で表の詳細な情報を返す
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def info(m, tables_str)
          log(m.raw, :incoming, :info)

          header = "rg-info"

          tables_str.split(' ').each do |table|
            body =
              begin
                "<#{table}>: #{@generator.info(table)} "
              rescue TableNotFound => not_found_error
                ": #{table_not_found_message(not_found_error)}"
              end
            message = "#{header}#{body}"

            m.target.send(message, true)
            log_notice(m.target, message)

            sleep(1)
          end
        end

        # 表が見つからなかったときのメッセージを返す
        # @param [TableNotFound] error エラー
        # @return [String]
        def table_not_found_message(error)
          "「#{error.table}」なんて表は見つからないのですわっ。"
        end
        private :table_not_found_message

        # 非公開の表を参照したときのメッセージを返す
        # @param [PrivateTable] error エラー
        # @return [String]
        def private_table_message(error)
          "表「#{error.table}」からは引けませんわっ。"
        end
        private :private_table_message

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
