# vim: fileencoding=utf-8

require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module Util
      # 複数行を NOTICE するメソッドのモジュール。
      module NoticeMultiLines
        include Logging

        private

        # 配列に収められた複数行のメッセージを NOTICE する
        # @param [Array<String>] lines NOTICE するメッセージ
        # @param [Cinch::Target] target NOTICE 先
        # @param [String] header メッセージの先頭に挿入する文字列
        # @return [void]
        def notice_multi_lines(lines, target, header = '')
          lines.each do |line|
            message = "#{header}#{line.chomp}"
            target.send(message, true)
            log_notice(target, message)
          end
        end

        # 改行文字を含むテキストで書かれた複数行のメッセージを NOTICE する
        # @param [String] messages 改行文字を含む送信メッセージ
        # @param [Cinch::Target] target NOTICE 先
        # @param [String] header メッセージの先頭に挿入する文字列
        # @return [void]
        def notice_multi_messages(messages, target, header = '')
          notice_multi_lines(messages.split("$/"), target, header)
        end
      end
    end
  end
end
