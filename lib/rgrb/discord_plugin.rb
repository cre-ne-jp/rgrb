# vim: fileencoding=utf-8

module RGRB
  module DiscordPlugin
    module ClassMethods
      attr_reader :plugin_name
      attr_reader :prefix
      attr_reader :suffix
      attr_reader :matchers
  
      def plugin_name=(new_name)
        if new_name.nil? && self.name
          @plugin_name = self.name.split('::').last.downcase
        else
          @plugin_name = new_name
        end
      end

      Matcher = Struct.new(
        :pattern,
        :use_prefix,
        :use_suffix,
        :method,
        :prefix,
        :suffix
      )

      def self.extended(by)
        by.instance_exec do
          self.plugin_name = nil
          @prefix = nil
          @suffix = nil
          @matchers = []
        end
      end
  
      # プラグインの設定
      # @param [Hash] settings
      # @return [void]
      def set(*args)
        case args.size
        when 1
          args.first.each do |k, v|
            self.send("#{k}=", v)
          end
        when 2
          self.send("#{args.first}=", args.last)
        else
          raise ArgumentError
        end
      end
  
      # メッセージ応答プラグインの作成
      # @param [String, Regexp] pattern 反応条件
      # @param [Hash] options 処理内容・設定
      # @option options [Boolean] use_prefix コマンドに接頭辞を使うか
      # @option options [Boolean] use_suffix コマンドに接尾辞を使うか
      # @option options [String] method 処理メソッド名
      # @option options [String, Regexp] プラグインの設定を上書きする接頭辞
      # @option options [String, Regexp] プラグインの設定を上書きする接尾辞
      # @return [Matcher]
      def match(pattern, options)
        options = {
          use_prefix: true,
          use_suffix: true,
          method: :execute,
          prefix: nil,
          suffix: nil
        }.merge(options)
  
        matcher = Matcher.new(
          pattern,
          *options.values_at(
            :use_prefix,
            :use_suffix,
            :method,
            :prefix,
            :suffix
          )
        )

        @matchers << matcher

        matcher
      end
    end

    def initialize(bot)
      @bot = bot

      __register_matchers
    end

    def self.included(by)
      by.extend(ClassMethods)
    end

    private

    def __register_matchers
      prefix = self.class.prefix
      suffix = self.class.suffix

      self.class.matchers.each do |matcher|
        _prefix = matcher.use_prefix ? matcher.prefix || prefix : nil
        _suffix = matcher.use_suffix ? matcher.suffix || suffix : nil
        pattern = /#{_prefix}#{matcher.pattern}#{_suffix}/

        @bot.message(content: pattern) do |event|
          self.send(matcher.method, event, pattern)
        end
      end
    end
  end
end
