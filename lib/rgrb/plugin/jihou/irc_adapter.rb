# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    # 時報プラグイン
    module Jihou
      # Jihou の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter
        include Util::Logging

        set(plugin_name: 'Jihou')
        listen_to(:'001', method: :connected)

        JIHOU_MESSAGE = "%{nick} が %{channel} の皆様に %{time} をお知らせします"

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @timing = config_data['Timer']
          @wait = config_data['Wait'] || 60

          prepare_timer
        end

        # サーバへの接続を検知して Timer を起動する
        # 再接続時のみ動作し、初回接続時は何もしない
        # @return [void]
        def connected
          prepare_timer if !@timer.defined? || @timer.stopped?
        end
        private :connected

        # 時報 Timer を起動する
        # 接続時の安定待ちのための遅延をする
        # @return [void]
        def prepare_timer
          Timer(0, {shots: 1, method: :start_timer}).start
        end
        private :define_timer

        # 実際に Timer を開始する
        # @return [void]
        def start_timer
          sleep(@wait)
          @timer = Timer(1, method: :jihou).start
        end

        # 毎日決められた時刻になったら発言用のメソッドを呼び出す
        # @return [void]
        def jihou
          time = Time.now
          if(channels = @timing[time.strftime('%T')])
            sendmes(channels, time)
          end
        end

        # 時報をチャンネルに発言する
        # @param [String] channels 発言するチャンネル
        # @param [Time] time 現在時刻
        # @return [void]
        def sendmes(channels, time)
          channels.each { |channel_name|
            message = JIHOU_MESSAGE % {
                nick: bot.nick,
                channel: channel_name,
                time: time.strftime('%Y年%m月%d日 %H時%M分%S秒')
            }
            Channel(channel_name).safe_notice(message)
            log_notice(channel_name, message)
          }
        end
      end
    end
  end
end
