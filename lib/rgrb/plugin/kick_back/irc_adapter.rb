# vim: fileencoding=utf-8

require 'rgrb/irc_plugin'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    # KICK されたとき、そのチャンネルに再度 JOIN するプラグイン
    module KickBack
      # KickBack の IRC アダプター
      class IrcAdapter
        include IrcPlugin
        include ConfigurableAdapter

        set(plugin_name: 'KickBack')
        listen_to(:kick, method: :kick)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @join_message =
            config_data['JoinMessage'] || '退出させるときは .part を使ってね☆'
        end

        # 自分が KICK されたら自動的にそのチャンネルに戻る
        # @param [Cinch::Message] m 送信されたメッセージ
        # @return [void]
        def kick(m)
          log_incoming(m)

          if m.params[1].downcase == bot.nick.downcase
            Channel(m.channel).join
            log_join(m.channel)
            send_notice(m.target, @join_message)
          end
        end
      end
    end
  end
end
