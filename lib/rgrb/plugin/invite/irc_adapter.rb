# vim: fileencoding=utf-8

require 'rgrb/irc_plugin'

module RGRB
  module Plugin
    # INVITE されたとき、そのチャンネルに JOIN するプラグイン
    module Invite
      # Invite の IRC アダプター
      class IrcAdapter
        include IrcPlugin

        set(plugin_name: 'Invite')
        listen_to(:invite, method: :invite)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @join_message =
            config_data['JoinMessage'] || [ 'ご招待いただきありがとう' ]
        end

        # 自分が INVITE されたら自動的にそのチャンネルに入る
        # @param [Cinch::Message] m 送信されたメッセージ
        # @return [void]
        def invite(m)
          log_incoming(m)
          Channel(m.channel).join
          log_join(m.channel)
          send_notice(m.channel, @join_message)
        end
      end
    end
  end
end
