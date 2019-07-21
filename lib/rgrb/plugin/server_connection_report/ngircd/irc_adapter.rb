# vim: fileencoding=utf-8

require 'rgrb/irc_plugin'
require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/irc_adapter_methods'

module RGRB
  module Plugin
    module ServerConnectionReport
      # ngIRCd 用サーバリレー監視プラグイン
      module Ngircd
        # ServerConnectionReport::Ngircd の IRC アダプター
        class IrcAdapter
          include ServerConnectionReport::IrcAdapterMethods

          # メッセージを送信するチャンネルのリスト
          attr_reader :channels_to_send

          # サーバメッセージのチャンネル名
          SERVER_MESSAGE_CHANNEL = '&SERVER'

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          REGISTERED_RE = /^Server "(#{HOSTNAME_RE})" registered/o
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          UNREGISTERED_RE = /^Server "(#{HOSTNAME_RE})" unregistered/o

          set(plugin_name: 'ServerConnectionReport::Ngircd')
          self.prefix = ''

          match(REGISTERED_RE, method: :joined)
          match(UNREGISTERED_RE, method: :disconnected)

          def initialize(*)
            super

            prepare_generators
          end

          # サーバ接続メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def joined(m, server)
            notice_joined(m, server) if m.channel == SERVER_MESSAGE_CHANNEL
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
