# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/util/notice_on_each_channel'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/generator'

module RGRB
  module Plugin
    module ServerConnectionReport
      # ngIRCd 用サーバリレー監視プラグイン
      module Ngircd
        # ServerConnectionReport::Ngircd の IRC アダプター
        class IrcAdapter
          include Cinch::Plugin
          include Util::NoticeOnEachChannel

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

            config_data = config[:plugin]
            @channels_to_send = config_data['ChannelsToSend']

            @generator = Generator.new
          end

          # サーバ接続メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def joined(m, server)
            if m.channel == SERVER_MESSAGE_CHANNEL
              log_incoming(m)
              notice_on_each_channel(@generator.joined(server))
            end
          end

          # サーバ切断メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def disconnected(m, server)
            if m.channel == SERVER_MESSAGE_CHANNEL
              log_incoming(m)
              notice_on_each_channel(@generator.disconnected(server))
            end
          end
        end
      end
    end
  end
end
