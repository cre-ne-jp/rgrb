# vim: fileencoding=utf-8

require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module Util
      # 複数行を NOTICE するメソッドのモジュール。
      module NoticeMultiLines
        include Logging

        private

        # 複数行を NOTICE する
        # @param [String] header メッセージの先頭につける文字列
        # @param [Array<String>] lines NOTICE するメッセージ
        # @param [Cinch::Target] target NOTICE 先
        # @return [void]
        def notice_multi_lines(header, lines, target)
          lines.each do |line|
            message = "#{header}#{line.chomp}"
            target.send(message, true)
            log_notice(target, message)
          end
        end

        # 複数行を NOTICE する
        # notice_multi_lines の、改行文字を含む文字列用ラッパー
        # @param [String] header メッセージの先頭につける文字列
        # @param [String] messages 改行文字を含む送信メッセージ
        # @param [Cinch::Target] target NOTICE 先
        # @return [void]
        def notice_multi_messages(header, messages, target)
          notice_multi_lines(header, messages.split("$/"), target)
        end
      end
    end
  end
end
