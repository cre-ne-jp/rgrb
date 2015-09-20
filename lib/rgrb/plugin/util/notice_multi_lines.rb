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
        # @param [Boolean] safe 表示不可能な文字を排除するかどうか
        # @return [void]
        def notice_multi_lines(lines, target, header = '', safe = false)
          lines.each do |line|
            message = "#{header}#{line.chomp}"
            if(safe)
              target.safe_send(message, true)
            else
              target.send(message, true)
            end
            log_notice(target, message)
          end
        end

        # 改行文字を含むテキストで書かれた複数行のメッセージを NOTICE する
        # @param [String] messages 改行文字を含む送信メッセージ
        # @param [Cinch::Target] target NOTICE 先
        # @param [String] header メッセージの先頭に挿入する文字列
        # @param [Boolean] safe 表示不可能な文字を排除するかどうか
        # @return [void]
        def notice_multi_messages(messages, target, header = '', safe = false)
          notice_multi_lines(messages.split("$/"), target, header, safe)
        end
      end
    end
  end
end
