# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin_base/adapter'

module RGRB
  module PluginBase
    module IrcAdapter
      # 共通で使用する他のモジュールを読み込む
      def self.included(by)
        by.include(Cinch::Plugin)
        by.include(Adapter)
      end

      # メッセージを NOTICE し、ログに書き出す
      # @param [String, Cinch::Target, Array<String>, Array<Cinch::Target>]
      #   targets NOTICE 先
      # @note Cinch::Channel, Cinch::User は、どちらも Cinch::Target の
      #   サブクラスのため、Cinch::Target と同様に扱う。
      # @param [String, Array<String>] messages NOTICE するメッセージ
      # @param [String] header メッセージの先頭に挿入する文字列
      # @param [Boolean] safe 表示不可能な文字を排除するかどうか
      # @return [void]
      def send_notice(targets, messages, header = '', safe = false)
        messages = messages.split($/) if messages.kind_of?(String)
        targets = to_cinch_target_array(targets)

        targets.each do |target|
          messages.each do |line|
            message = "#{header}#{line.chomp}"

            if safe
              target.safe_send(message, true)
            else
              target.send(message, true)
            end

            log_notice(target, message)
          end
        end
      end

      # 複数の送信先に NOTICE する
      # v1.0.5 より非推奨メソッド。send_notice に統合する。
      #
      # channels_to_send メソッドを定義すること。
      #
      # @param [String] message NOTICE するメッセージ
      # @param [Boolean] safe 表示不可能な文字を排除するかどうか
      # @return [void]
      def notice_on_each_channel(message, safe = false)
        send_notice(message, channels_to_send, '', safe)
        log('IrcPlugin#notice_on_each_channel: deprecated', :warn)
      end

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

      private

      # ジェネレータで使うロガーを返す
      # @return [self]
      def logger_for_generator
        self
      end

      # メッセージの送信先を Cinch::Target の配列に変換する
      # @param [String, Cinch::Target, Array<String>, Array<Cinch::Target>]
      #   targets 送信先
      # @return [Array<Cinch::Target>]
      # @note Cinch::Channel, Cinch::User は、どちらも Cinch::Target の
      #   サブクラスのため、Cinch::Target と同様に扱う。
      def to_cinch_target_array(targets)
        case targets
        when String
          targets.split($/).map { |name| Target(name) }
        when Cinch::Target, Cinch::Channel, Cinch::User
          [targets]
        when Array
          targets.map { |target| to_cinch_target(target) }
        else
          raise TypeError, targets.to_s
        end
      end

      # メッセージの送信先を Cinch::Target に変換する
      # @param [String, Cinch::Target] 送信先
      # @return [Cinch::Target]
      # @note Cinch::Channel, Cinch::User は、どちらも Cinch::Target の
      #   サブクラスのため、Cinch::Target と同様に扱う。
      def to_cinch_target(target)
        case target
        when String
          Target(target)
        when Cinch::Target, Cinch::Channel, Cinch::User
          target
        else
          raise TypeError, target.to_s
        end
      end
    end
  end
end
