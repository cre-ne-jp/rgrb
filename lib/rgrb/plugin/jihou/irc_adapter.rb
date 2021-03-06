# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'

module RGRB
  module Plugin
    # 時報プラグイン
    module Jihou
      # Jihou の IRC アダプター
      class IrcAdapter
        include PluginBase::IrcAdapter

        set(plugin_name: 'Jihou')
        listen_to(:connect, method: :connected)

        JIHOU_MESSAGE = "%{nick} が %{channel} の皆様に %{time} をお知らせします"

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @timing = config_data['Timer']
          @wait = config_data['Wait'] || 60

          @timer = Timer(1, {
            method: :jihou,
            start_automatically: false
          })
        end

        # サーバへの接続を検知して Timer を起動する
        # @return [void]
        def connected(m)
          sleep(@wait)
          @timer.start if @timer.stopped?
        end
        private :connected

        # 毎日決められた時刻になったら発言用のメソッドを呼び出す
        # @return [void]
        def jihou
          time = Time.now
          if(channels = @timing[time.strftime('%T')])
            sendmes(channels, time)
          end
        end

        # 時報をチャンネルに発言する
        # @param [Hash] channels 発言するチャンネル
        # @param [Time] time 現在時刻
        # @return [void]
        def sendmes(channels, time)
          channels.each do |channel_name, message|
            channel = Channel(channel_name)

            if(message.empty?)
              message = JIHOU_MESSAGE % {
                nick: bot.nick,
                channel: channel_name,
                time: time.strftime('%Y年%m月%d日 %H時%M分%S秒')
              }
            end

            send_notice(channel, message, '', true)
          end
        end
      end
    end
  end
end
