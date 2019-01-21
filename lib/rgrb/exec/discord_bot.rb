# vim: fileencoding=utf-8

require 'lumberjack'
require 'discordrb'
require 'optparse'
require 'sysexits'

require 'rgrb/version'
require 'rgrb/config'
require 'rgrb/plugins_loader'

module RGRB
  module Exec
    # Discord ボットの実行ファイルの処理を担うクラス
    module DiscordBot
      extend self

      # プログラムを実行する
      # @param [String] root_path RGRB のルートディレクトリの絶対パス
      # @param [Array<String>] argv コマンドライン引数の配列
      # @return [void]
      def run(root_path, argv)
        options = parse_options(argv)
        config_id = options[:config_id]
        log_level = options[:log_level]

        logger = new_logger(log_level)
        config = load_config(config_id, root_path, logger)
        discord_adapters = load_discord_adapters(config, logger)
        plugin_options = extract_plugin_options(
          config, discord_adapters, root_path, logger
        )
        bot = new_bot(
          config, discord_adapters, plugin_options, log_level, logger
        )

        set_signal_handler(bot)
        bot.run

        logger.warn('ボットは終了しました')
      end
      module_function :run

      private

      # 設定を読み込む
      # @param [String] config_id 設定 ID
      # @param [String] root_path RGRB のルートディレクトリの絶対パス
      # @param [Lumberjack::Logger] logger ロガー
      # @return [Config]
      def load_config(config_id, root_path, logger)
        config = Config.load_yaml_file(config_id, "#{root_path}/config")
        logger.warn("設定 #{config_id} を読み込みました")

        config
      rescue => e
        logger.fatal('設定ファイルの読み込みに失敗しました')
        logger.fatal(e)

        Sysexits.exit(:config_error)
      end

      # プラグインの Discord アダプタを読み込む
      # @param [Config] config RGRB の設定
      # @param [Lumberjack::Logger] logger ロガー
      # @return [Array<RGRB::DiscordPlugin>] 読み込まれた Discord アダプタの配列
      def load_discord_adapters(config, logger)
        loader = PluginsLoader.new(config)
        discord_adapters = loader.load_each(:DiscordAdapter)

        discord_adapters.each do |adapter|
          logger.warn(
            "プラグイン #{adapter.plugin_name} を読み込みました"
          )
        end

        discord_adapters
      rescue LoadError, StandardError => e
        logger.fatal('プラグインの読み込みに失敗しました')
        logger.fatal(e)

        Sysexits.exit(:config_error)
      end

      # 設定から読み込まれたプラグインの設定を抽出する
      # @param [Config] config RGRB の設定
      # @param [Array<RGRB::DiscordPlugin>] loaded_discord_adapters
      #   読み込まれた Discord アダプタの配列
      # @param [String] root_path RGRB のルートディレクトリの絶対パス
      # @param [Lumberjack::Logger] logger ロガー
      # @return [Hash] プラグイン設定
      def extract_plugin_options(
        config, loaded_discord_adapters, root_path, logger
      )
        plugin_options = {}

        loaded_discord_adapters.each do |adapter|
          plugin_name = adapter.plugin_name
          plugin_config = config.plugin_config[plugin_name] || {}

          plugin_options[adapter] = {
            root_path: root_path,
            plugin: plugin_config
          }

          logger.warn(
            "プラグイン #{plugin_name} の設定を読み込みました"
          ) if plugin_config
        end

        plugin_options
      rescue => e
        logger.fatal('プラグイン設定の読み込みに失敗しました')
        logger.fatal(e)

        Sysexits.exit(:config_error)
      end

      # Discord ボットを作り、設定して返す
      # @param [Config] config RGRB の設定
      # @param [Array<RGRB::DiscordPlugin>] discord_adapters Discord アダプタの配列
      # @param [Hash] plugin_options プラグイン設定
      # @param [Symbol] log_level ログレベル
      # @param [Lumberjack::Logger] logger ロガー
      # @return [Discordrb::Commands::CommandBot]
      def new_bot(config, discord_adapters, plugin_options, log_level, logger)
        bot_config = config.discord_bot

        bot = Discordrb::Commands::CommandBot.new(
          token: bot_config['Token'],
          client_id: bot_config['ClientID'],
          prefix: ''
        )

        # Lumberjack 用のログモードから、
        # Discordrb 内部処理用のログモードを選択・設定
        bot.mode = case log_level
          when :info
            :verbose
          when :debug
            :debug
          else
            :normal
          end

        # バージョン情報を返すコマンド
        bot.message(content: '.version') do |event|
          unless event.user.current_bot?
            event << "#{event.user.mention} RGRB #{RGRB::VERSION_WITH_COMMIT_ID}"
          end
        end

        # 独自実装のプラグイン機能を読み込む
        discord_adapters.each do |adapter|
          adapter.new(bot, (plugin_options[adapter] || {}), logger)
        end

        logger.warn('ボットが生成されました')

        bot
      rescue => e
        logger.fatal('Discord ボットの生成に失敗しました')
        logger.fatal(e)

        Sysexits.exit(:config_error)
      end

      # オプションを解析する
      # @return [Hash]
      def parse_options(argv)
        default_options = {
          config_id: 'rgrb',
          log_level: :warn
        }
        options = {}

        OptionParser.new do |opt|
          opt.banner = "使用法: #{opt.program_name} [オプション]"
          opt.version = RGRB::VERSION_WITH_COMMIT_ID

          opt.summary_indent = ' ' * 2
          opt.summary_width = 24

          opt.separator('')
          opt.separator('汎用ボット RGRB - Discord ボット')

          opt.separator('')
          opt.separator('オプション:')

          opt.on(
            '-c', '--config=CONFIG_ID',
            '設定 CONFIG_ID を読み込みます'
          ) do |config_id|
            options[:config_id] = config_id
          end

          opt.on(
            '-v', '--verbose',
            'ログを冗長にします'
          ) do
            options[:log_level] = :info
          end

          opt.on(
            '--debug',
            'デバッグモード。ログを最も冗長にします。'
          ) do
            options[:log_level] = :debug
          end

          opt.parse(argv)
        end

        default_options.merge(options)
      end

      # 新しいロガーを作り、設定して返す
      # @param [Symbol] log_level ログレベル
      # @return [Logger]
      def new_logger(log_level)
        lumberjack_log_level =
          Lumberjack::Severity.const_get(log_level.upcase)

        Lumberjack::Logger.new(
          $stdout,
          progname: self.to_s,
          level: lumberjack_log_level
        )
      end

      # シグナルハンドラを設定する
      # @param [Discordrb::Commands::CommandBot] bot Discord ボット
      # @return [void]
      def set_signal_handler(bot)
        # シグナルを捕捉し、ボットを終了させる処理
        # trap 内で普通に bot.quit すると ThreadError が出るので
        # 新しい Thread で包む
        %i(SIGINT SIGTERM).each do |signal|
          Signal.trap(signal) do
            Thread.new(signal) do |sig|
              bot.stop(true)
            end
          end
        end
      end
    end
  end
end
