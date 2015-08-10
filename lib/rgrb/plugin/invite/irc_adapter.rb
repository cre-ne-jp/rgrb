# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    # INVITE されたとき、そのチャンネルに JOIN するプラグイン
    module Invite
      # Invite の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'Invite')
        listen_to(:invite, method: :invite)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @join_message =
            config_data['JoinMessage'] || 'ご招待いただきありがとう'
        end

        # 自分が INVITE されたら自動的にそのチャンネルに入る
        # @param [Cinch::Message] m 送信されたメッセージ
        # @return [void]
        def invite(m)
          Channel(m.channel).join
          @join_message.each_line do |line|
            message = line.chomp
            m.target.send(message, true)
            log("<JOIN on #{m.channel}> #{message}", :outgoing, :info)
          end
        end
      end
    end
  end
end
