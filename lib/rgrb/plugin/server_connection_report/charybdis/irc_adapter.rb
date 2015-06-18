# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/util/notice_on_each_channel'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/generator'

module RGRB
  module Plugin
    module ServerConnectionReport
      # Charybdis 用サーバリレー監視プラグイン。
      #
      # サーバの接続状態が変化したときに Oper ユーザーに送信される PRIVMSG
      # を解析する。
      # したがって、基本的にボットが Oper であることが必要である。
      #
      # 送信元を指定するオプション AllowedSenders にサーバアドレスを追加
      # し、受信するメッセージを絞る。
      module Charybdis
        # ServerConnectionReport::Charybdis の IRC アダプター
        class IrcAdapter
          include Cinch::Plugin
          include Util::NoticeOnEachChannel
          include Util::Logging

          # メッセージを送信するチャンネルのリスト
          attr_reader :channels_to_send

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          NETJOIN_RE =
            /^\*\*\* Notice -- Netjoin #{HOSTNAME_RE} <-> (#{HOSTNAME_RE})/o
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          NETSPLIT_RE =
            /^\*\*\* Notice -- Netsplit #{HOSTNAME_RE} <-> (#{HOSTNAME_RE}) \(.+?\) \((.+)\)/o

          set(plugin_name: 'ServerConnectionReport::Charybdis')
          self.prefix = ''
          self.react_on = :notice

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          match(NETJOIN_RE, method: :joined)
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          match(NETSPLIT_RE, method: :disconnected)

          def initialize(*)
            super

            config_data = config[:plugin]
            @channels_to_send = config_data['ChannelsToSend'] || []

            @generator = Generator.new
          end

          # サーバ接続メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def joined(m, server)
            if m.server
              log_incoming(m)
              notice_on_each_channel(@generator.joined(server))
            end
          end

          # サーバ切断メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @param [String] comment コメント
          # @return [void]
          def disconnected(m, server, comment)
            if m.server
              log_incoming(m)
              notice_on_each_channel(
                @generator.disconnected(server, comment)
              )
            end
          end
        end
      end
    end
  end
end
