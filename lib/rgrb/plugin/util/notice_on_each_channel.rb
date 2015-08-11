# vim: fileencoding=utf-8

require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module Util
      # 各チャンネルで NOTICE するメソッドのモジュール。
      module NoticeOnEachChannel
        include Logging

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
            channel = Channel(channel_name)

            if safe
              channel.safe_notice(message)
            else
              channel.notice(message)
            end

            log_notice(channel, message)
          end
        end
      end
    end
  end
end
