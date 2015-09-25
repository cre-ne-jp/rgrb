# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/notice_multi_lines'

module RGRB
  module Plugin
    # INVITE されたとき、そのチャンネルに JOIN するプラグイン
    module Invite
      # Invite の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter
        include Util::NoticeMultiLines

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
          Channel(m.channel).join
          notice_multi_lines(@join_message, m.channel)
        end
      end
    end
  end
end
