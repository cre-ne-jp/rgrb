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

        match(/^Server "([\w\.]+)" registered/, method: :registered)
        match(/^Server "([\w\.]+)" unregistered/, method: :unregistered)

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

      end
    end
  end
end
