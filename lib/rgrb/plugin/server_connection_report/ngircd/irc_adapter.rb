# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/util/notice_on_each_channel'
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

          set(plugin_name: 'ServerConnectionReport::Ngircd')
          self.prefix = ''

          match(/^Server "([\w\.]+)" registered/, method: :joined)
          match(/^Server "([\w\.]+)" unregistered/, method: :disconnected)

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
          def registered(m, server)
            return unless m.channel == SERVER_MESSAGE_CHANNEL

            notice_on_each_channel(@generator.joined(server))
          end

          # サーバ切断メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def unregistered(m, server)
            return unless m.channel == SERVER_MESSAGE_CHANNEL

            notice_on_each_channel(@generator.unregistered(server))
          end
        end
      end
    end
  end
end
