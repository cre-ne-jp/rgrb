# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Util
      # 各チャンネルで NOTICE するメソッドを追加する。
      module NoticeOnEachChannel
        private

        # 各チャンネルで NOTICE する
        #
        # channels_to_send メソッドを定義すること。
        #
        # @param [String] message NOTICE するメッセージ
        # @param [Boolean] safe 表示不可能な文字を排除するかどうか
        # @return [void]
        def notice_on_each_channel(message, safe = false)
          channels_to_send.each do |channel_name|
            if safe
              Channel(channel_name).safe_notice(message)
            else
              Channel(channel_name).notice(message)
            end
          end
        end
      end
    end
  end
end
