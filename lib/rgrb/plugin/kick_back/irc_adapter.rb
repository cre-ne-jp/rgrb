# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    module KickBack
      # KickBack の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
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
          if m.params[1] == m.bot.to_s
            log(m.raw, :incoming, :info)
            Channel(m.channel).join()
            m.target.send(@join_message, true)
            log("<JOIN on #{m.channel}> #{@join_message}", :outgoing, :info)
          end
        end
      end
    end
  end
end
