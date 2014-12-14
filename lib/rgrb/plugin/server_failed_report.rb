# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module Plugin
    # キーワード検索プラグイン
    class ServerFailedReport
      include Cinch::Plugin

      # サーバーがリレーから切断した際のメッセージ
      FAIL_MESSAGE = '"%s"がリレーから切り離されました。'
      # サーバーがリレーした際のメッセージ
      CONNECT_MESSAGE = '"%s"がリレーしました。'

      # メッセージ出力先
      @channels_to_send = ''

      self.prefix = ''
      match(/Server "([\w\.]+)" unregistered/, method: :fail_srv)
      match(/Server "([\w\.]+)" registered/, method: :connect_srv)

      def initialize(*args)
        super
        plugin_config = config[:rgrb_config].plugin_config(self.class)

        @channels_to_send = plugin_config['ChannelsToSend']
      end

      # NOTICE でサーバー切断メッセージを出す
      # @return [void]
      def fail_srv(m, srvname)
        return unless m.channel == '&SERVER'
        mes = FAIL_MESSAGE % srvname
        @channels_to_send.each do |channel_name|
          Channel(channel_name).safe_notice(mes)
        end
      end

      # NOTICE でサーバー接続メッセージを返す
      # @return [void]
      def connect_srv(m, srvname)
        return unless m.channel == '&SERVER'
        mes = CONNECT_MESSAGE % srvname
        @channels_to_send.each do |channel_name|
          Channel(channel_name).safe_notice(mes)
        end
      end
    end
  end
end
