# vim: fileencoding=utf-8

require 'rgrb/plugin_base/adapter'

module RGRB
  module PluginBase
    module DiscordAdapter
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
        # @param [Symbol] type 反応メッセージの種類
        # @param [Boolean] use_prefix 接頭辞を使うか
        # @param [Boolean] use_suffix 接尾辞を使うか
        # @param [Symbol] 処理メソッド名
        # @param [String, Regexp] prefix 接頭辞
        # @param [String, Regexp] suffix 接尾辞
        Matcher = Struct.new(
          :pattern,
          :type,
          :use_prefix,
          :use_suffix,
          :method,
          :prefix,
          :suffix
        )
  
        def self.extended(by)
          by.instance_exec do
            self.plugin_name = nil
            @prefix = /^\./
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
    
        # 通常メッセージ応答プラグインの作成
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
            prefix: nil,
            suffix: nil
          }.merge(options)
    
          matcher = Matcher.new(
            pattern,
            :message,
            *options.values_at(
              :use_prefix,
              :use_suffix,
              :method,
              :prefix,
              :suffix
            )
          ).freeze
  
          @matchers << matcher
  
          matcher
        end
  
        # メンション応答プラグインの作成
        # @param [String, Regexp] pattern 反応条件
        # @param [Hash] options 処理内容・設定
        # @option options [Boolean] use_prefix コマンドに接頭辞を使うか
        # @option options [Boolean] use_suffix コマンドに接尾辞を使うか
        # @option options [String] method 処理メソッド名
        # @option options [String, Regexp] prefix プラグインの設定を上書きする接頭辞
        # @option options [String, Regexp] suffix プラグインの設定を上書きする接尾辞
        # @return [Matcher]
        def mention(pattern, options)
          options = {
            use_prefix: true,
            use_suffix: true,
            method: :execute,
            prefix: nil,
            suffix: nil
          }.merge(options)
  
          matcher = Matcher.new(
            pattern,
            :mention,
            *options.values_at(
              :use_prefix,
              :use_suffix,
              :method,
              :prefix,
              :suffix
            )
          ).freeze
  
          @matchers << matcher
  
          matcher
        end
      end
  
      attr_reader :config
  
      # 共通で使用する他のモジュールを読み込む
      def self.included(by)
        by.extend(ClassMethods)
        by.include(Adapter)
      end
  
      # コンストラクタ
      # @param [Discordrb::CommandBot] bot Discordrb のボットインスタンス
      # @param [Hash] options プラグイン設定
      # @param [] logger ロガー
      # @return [DiscordPlugin]
      def initialize(bot, options, logger)
        @bot = bot
        @config = options
        @logger = logger
        @thread_group = ThreadGroup.new
        @mutex = Mutex.new
  
        __register_matchers
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
  
          case matcher.type
          when :message
            @bot.message(contains: pattern) do |event|
              event_handler(event, pattern, matcher)
            end
          when :mention
            @bot.mention(contains: pattern) do |event|
              event_handler(event, pattern, matcher)
            end
          else
            @logger.warn("[ERROR] No selected message type: #{matcher.method}")
          end
        end
      end
  
      # プラグインを設定する
      # @param [] event イベント
      # @param [Regexp] pattern 反応パターン
      # @param [Matcher] matcher 反応条件設定
      # @return [void]
      def event_handler(event, pattern, matcher)
        match_data = event.message.text.match(pattern)
        thread = Thread.new do
          log_debug("[Thread start] For #{self}: #{Thread.current} -- #{@thread_group.list.size} in total.")
          begin
            self.send(matcher.method, event, *match_data[1..-1])
          rescue => e
            log_exception(e)
          ensure
            log_debug("[Thread done] For #{self}: #{Thread.current} -- #{@thread_group.list.size - 1} remaining.")
          end
        end
        @thread_group.add(thread)
      end
  
      # メッセージをチャンネルに送信する
      # @param [Discordrb::Channel] target 送信先
      # @param [String, Array] message メッセージ
      # @return [void]
      def send_channel(target, message, header = '')
        message = Array(message) if message.kind_of?(String)
  
        _message = message.map do |line|
          message = "#{header}#{line}"
        end.join("\n")
  
        target.send_message(_message)
        log_send_channel(target, _message)
      end
  
      # ログを出力させる
      # @param [String] content 出力するイベント
      # @param [Symbol] type ログの種類
      # @param [Symbol] level ログレベル
      # @return [void]
      def log(content, type = :debug, level = type)
        message = case type
        when :incoming
          ">> #{content}"
        when :outgoing
          "<< #{content}"
        else
          content
        end
  
        @mutex.synchronize do
          message.each_line do |line|
            @logger.add(level, line)
          end
        end
      end
  
      # ボットへの入力ログを出力する
      # @param [Discordrb::Events::*] event 出力するイベント
      # @return [void]
      def log_incoming(event)
        log("#{format_user(event.author)} #{format_channel(event.channel)}: #{event.content.chomp}", :incoming, :info)
      end
  
      # ボットへからの送信ログを出力する
      # @param [Discordrb::Events::*] target 送信先
      # @param [String] message メッセージ
      # @return [void]
      def log_send_channel(target, message)
        log(%Q(<SEND to #{format_channel(target)}> "#{message.chomp}"), :outgoing, :info)
      end
  
      def log_debug(message)
        log(message, :debug)
      end
  
      def log_exception(e)
        #log(e.backtrace.reverse.join("\n"), :exception, :error)
        log(e.full_message, :exception, :error)
      end
  
      # ユーザー情報を整形する
      # @param [Discordrb::User] author 出力するイベント
      # @return [String]
      def format_user(author)
        "#{author.username}[#{author.id}]@#{format_server(author.server)}"
      end
  
      # チャンネル情報を整形する
      # @param [Discordrb::Channel] channel 出力するイベント
      # @return [String]
      def format_channel(channel)
        "##{channel.name}[#{channel.id}]@#{format_server(channel.server)}"
      end
  
      # サーバー情報を整形する
      # @param [Discordrb::Server] server 出力するイベント
      # @return [String]
      def format_server(server)
        "#{server.name}[#{server.id}(#{server.region_id})]"
      end
    end
  end
end
