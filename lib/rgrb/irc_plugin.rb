# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module IrcPlugin
    def self.included(by)
      by.include(Cinch::Plugin)

      # 入ってきたメッセージをログに残す
      # @param [Cinch::Message] m メッセージ
      # @return [void]
      def log_incoming(m)
        log(m.raw, :incoming, :info)
      end

      # NOTICE をログに残す
      # @param [Cinch::Target] target NOTICE の対象
      # @param [String] message メッセージ
      # @return [void]
      def log_notice(target, message)
        log("<NOTICE to #{target.name}> #{message.inspect}", :outgoing, :info)
      end

      # JOIN をログに残す
      # @param [Cinch::Channel] channel
      # @return [void]
      def log_join(channel)
        log("<JOIN on #{channel}>", :outgoing, :info)
      end

      # PART をログに残す
      # @param [Cinch::Channel] channel
      # @param [String] message 退出メッセージ
      # @return [void]
      def log_part(channel, message)
        log("<PART from #{channel}> #{message.inspect}", :outgoing, :info)
      end
    end
  end
end
