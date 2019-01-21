# vim: fileencoding=utf-8

module RGRB
  module DiscordPlugin
    module ClassMethods
      # [String] プラグイン名
      attr_reader :plugin_name
      # [String, Regexp] プラグイン共通の初期接頭辞
      attr_accessor :prefix
      # [String, Regexp] プラグイン共通の初期接尾辞
      attr_accessor :suffix
      # [Array<Matcher>] 反応条件一覧
      attr_reader :matchers
  
      # プラグイン名を設定する
      # @param [String] new_name 設定する文字列
      # @return [void]
      def plugin_name=(new_name)
        if new_name.nil? && self.name
          @plugin_name = self.name.split('::').last.downcase
        else
          @plugin_name = new_name
        end
      end

      # コマンドの条件
      # @param [String, Regexp] pattern 反応条件
      # @param [Boolean] use_prefix 接頭辞を使うか
      # @param [Boolean] use_suffix 接尾辞を使うか
      # @param [Symbol] 処理メソッド名
      # @param [String, Regexp] prefix 接頭辞
      # @param [String, Regexp] suffix 接尾辞
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
      # @param [Hash] args 設定内容
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
      # @option options [String, Regexp] prefix プラグインの設定を上書きする接頭辞
      # @option options [String, Regexp] suffix プラグインの設定を上書きする接尾辞
      # @return [Matcher]
      def match(pattern, options)
        options = {
          use_prefix: true,
          use_suffix: true,
          method: :execute,
          prefix: /\./,
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

    attr_reader :config

    # コンストラクタ
    # @param [Discordrb::CommandBot] bot Discordrb のボットインスタンス
    # @param [Hash] options プラグイン設定
    # @return [DiscordPlugin]
    def initialize(bot, options)
      @bot = bot
      @config = options

      __register_matchers
    end

    def self.included(by)
      by.extend(ClassMethods)
    end

    private

    # 反応条件(Matcher)を設定する
    # @return [void]
    def __register_matchers
      prefix = self.class.prefix
      suffix = self.class.suffix

      self.class.matchers.each do |matcher|
        _prefix = matcher.use_prefix ? matcher.prefix || prefix : nil
        _suffix = matcher.use_suffix ? matcher.suffix || suffix : nil
        pattern = /#{_prefix}#{matcher.pattern}#{_suffix}/

        @bot.message(content: pattern) do |event|
          match_data = event.message.text.match(pattern)
          self.send(matcher.method, event, *match_data[1..-1])
        end
      end
    end
  end
end
