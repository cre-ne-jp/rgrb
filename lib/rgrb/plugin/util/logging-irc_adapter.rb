# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Util
      # プラグインのログ記録関連メソッドを集めたモジュール。
      module Logging
        private

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
end
