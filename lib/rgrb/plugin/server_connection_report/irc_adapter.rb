# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/server_connection_report/generator'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # ServerConnectionReport の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        # サーバメッセージのチャンネル名
        SERVER_MESSAGE_CHANNEL = '&SERVER'

        set(plugin_name: 'ServerConnectionReport')

        self.prefix = ''
        match(/^Server "([\w\.]+)" registered/, method: :registered)
        match(/^Server "([\w\.]+)" unregistered/, method: :unregistered)

        def initialize(*)
          super

          config_data = config[:plugin]
          @channels_to_send = config_data['ChannelsToSend']

          @generator = Generator.new
        end

        # サーバ接続メッセージを NOTICE する
        # @return [void]
        def registered(m, server)
          return unless m.channel == SERVER_MESSAGE_CHANNEL

          notice_on_each_channel(@generator.registered(server))
        end

        # サーバ切断メッセージを NOTICE する
        # @return [void]
        def unregistered(m, server)
          return unless m.channel == SERVER_MESSAGE_CHANNEL

          notice_on_each_channel(@generator.unregistered(server))
        end

        # 各チャンネルで NOTICE する
        # @param [String] message NOTICE するメッセージ
        # @return [void]
        def notice_on_each_channel(message)
          @channels_to_send.each do |channel_name|
            Channel(channel_name).send(message, true)
          end
        end
        private :notice_on_each_channel
      end
    end
  end
end
