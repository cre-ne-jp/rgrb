# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/irc_adapter_methods'

module RGRB
  module Plugin
    module ServerConnectionReport
      # Atheme-Services 用サーバリレー監視プラグイン
      module AthemeServices
        # ServerConnectionReport::AthemeServices の IRC アダプター
        class IrcAdapter
          include ServerConnectionReport::IrcAdapterMethods

          # サーバメッセージのチャンネル名
          SERVER_MESSAGE_CHANNEL = '#services'

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          SERVER_ADD_RE = /^server_add\(\): (#{HOSTNAME_RE})/o
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          SERVER_DELETE_RE = /^server_delete\(\): (#{HOSTNAME_RE})/o

          set(plugin_name: 'ServerConnectionReport::AthemeServices')
          self.prefix = ''

          match(SERVER_ADD_RE, method: :joined)
          match(SERVER_DELETE_RE, method: :disconnected)

          def initialize(*)
            super

            prepare_generators
          end

          # サーバ接続メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def joined(m, server)
             notice_joined(m, server) if m.channel.name == SERVER_MESSAGE_CHANNEL
          end

          # サーバ切断メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def disconnected(m, server)
            notice_disconnected(m, server, comment) if m.channel == SERVER_MESSAGE_CHANNEL
          end
        end
      end
    end
  end
end
