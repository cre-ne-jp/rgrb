# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/generator'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/private_table'

module RGRB
  module Plugin
    module RandomGenerator
      # RandomGenerator の IRC アダプター
      class IrcAdapter
        include PluginBase::IrcAdapter

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

          messages = tables_str.split(' ').map do |table|
            begin
              "#{@generator.rg(table)} ですわ☆".
                split($/).
                map { |line| "<#{table}>: #{line}" }
            rescue TableNotFound => not_found_error
              ": #{table_not_found_message(not_found_error)}"
            rescue PrivateTable => private_table_error
              ": #{private_table_message(private_table_error)}"
            end
          end

          send_notice(m.target, messages.flatten, "rg[#{m.user.nick}]")
        end

        # NOTICE で表の説明を返す
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def desc(m, tables_str)
          log_incoming(m)

          messages = tables_str.split(' ').map do |table|
            begin
              "<#{table}>: #{@generator.desc(table)} "
            rescue TableNotFound => not_found_error
              ": #{table_not_found_message(not_found_error)}"
            end
          end

          send_notice(m.target, messages, 'rg-desc')
        end

        # NOTICE で表の詳細な情報を返す
        # @param [Cinch::Message] m メッセージ
        # @param [String] tables_str 表のリスト
        # @return [void]
        def info(m, tables_str)
          log_incoming(m)

          messages = tables_str.split(' ').map do |table|
            begin
              "<#{table}>: #{@generator.info(table)} "
            rescue TableNotFound => not_found_error
              ": #{table_not_found_message(not_found_error)}"
            end
          end

          send_notice(m.target, messages, 'rg-info')
        end

        # 表の名前を一覧する
        # @param [Cinch::Message] m メッセージ
        # @return [String]
        def list(m)
          log_incoming(m)
          message = @list_reply.empty? ? @generator.list.join(', ') : @list_reply
          send_notice(m.target, message, 'rg-list: ')
        end

        private

        # 表が見つからなかったときのメッセージを返す
        # @param [TableNotFound] error エラー
        # @return [String]
        def table_not_found_message(error)
          "「#{error.table}」なんて表は見つからないのですわっ。"
        end

        # 非公開の表を参照したときのメッセージを返す
        # @param [PrivateTable] error エラー
        # @return [String]
        def private_table_message(error)
          "表「#{error.table}」からは引けませんわっ。"
        end
      end
    end
  end
end
