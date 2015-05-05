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

        set(plugin_name: 'ServerConnectionReport')
        self.prefix = ''

        def initialize(*)
          super

          config_data = config[:plugin]
          @using_serverd = config_data['UsingServerD']

          require "rgrb/plugin/server_connection_report/server_#{@using_serverd}"
          @generator = Generator.new
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
