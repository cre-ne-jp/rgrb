# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/notice_multi_lines'
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
        include Util::NoticeMultiLines

        set(plugin_name: 'RandomGenerator')
        match(/rg#{SPACES_RE}#{TABLES_RE}/o, method: :rg)
        match(/rg-desc#{SPACES_RE}#{TABLES_RE}/o, method: :desc)
        match(/rg-info#{SPACES_RE}#{TABLES_RE}/o, method: :info)
        match(/rg-list/, method: :list)

        def initialize(*)
          super

          config_data = config[:plugin]
          @list_reply = config_data['ListReply'] || ''

          prepare_generator
        end

        # NOTICE でジェネレート結果を返す
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def rg(m, tables_str)
          log_incoming(m)

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

            notice_multi_lines(lines, m.target, header)

            sleep(1)
          end
        end

        # NOTICE で表の説明を返す
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def desc(m, tables_str)
          log_incoming(m)

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
          log_incoming(m)

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

        # 表の名前を一覧する
        # @param [Cinch::Message] m メッセージ
        # @return [String]
        def list(m)
          log(m.raw, :incoming, :info)

          if(@list_reply == '')
            message = "rg-list: #{@generator.list.join(', ')}"
          else
            message = "rg-list: #{@list_reply}"
          end

          m.target.send(message, true)
          log_notice(m.target, message)

          sleep(1)
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

      end
    end
  end
end
