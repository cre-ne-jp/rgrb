# vim: fileencoding=utf-8

require 'lumberjack'
require 'cinch'
require 'optparse'
require 'sysexits'

require 'rgrb/version'
require 'rgrb/config'
require 'rgrb/plugins_loader'

module RGRB
  module Exec
    # IRC ボットの実行ファイルの処理を担うクラス
    class IRCBot
      # 既定の設定 ID
      DEFAULT_CONFIG_ID = 'rgrb'

      # 新しい RGRB::Exec::IRCBot インスタンスを返す
      # @param [String] rgrb_root_path RGRB のルートディレクトリの絶対パス
      # @param [Array<String>] argv コマンドライン引数の配列
      def initialize(rgrb_root_path, argv)
        @root_path = rgrb_root_path
        @argv = argv

        @debug = false
        @config_id = DEFAULT_CONFIG_ID
        @opt = new_opt_parser
        @logger = new_logger
      end

      # プログラムを実行する
      # @return [void]
      def execute
        @opt.parse!(@argv)

        @logger.level =
          if @debug
            Lumberjack::Logger::DEBUG
          else
            Lumberjack::Logger::INFO
          end

        @config = load_config(@config_id, @root_path, @logger)
        load_plugins
        bot = new_bot

        # シグナルを捕捉し、ボットを終了させる処理
        # trap 内で普通に bot.quit すると ThreadError が出るので
        # 新しい Thread で包む
        %i(SIGINT SIGTERM).each do |signal|
          Signal.trap(signal) do
            Thread.new(signal) do |sig|
              bot.quit("Caught #{sig}")
            end
          end
        end

        bot.start
      end

      # エラーメッセージを表示する
      # @param [String] message エラーメッセージ
      # @return [void]
      def print_error(message)
        $stderr.puts("#{@opt.program_name}: #{message}")
      end
      private :print_error

      # 設定を読み込む
      # @param [String] config_id 設定 ID
      # @param [String] root_path RGRB のルートディレクトリの絶対パス
      # @param [Logger] logger ロガー
      # @raise [ArgumentError] config_id に '../' が含まれる場合
      # @return [Config]
      def load_config(config_id, root_path, logger)
        if config_id.include?('../')
          fail(
            ArgumentError,
            "#{config_id}: ディレクトリトラバーサルの疑い"
          )
        end

        yaml_path = "#{root_path}/config/#{config_id}.yaml"
        config = RGRB::Config.load_yaml_file(yaml_path)
        logger.warn("設定 #{config_id} を読み込みました")

        config
      rescue => e
        logger.fatal('設定ファイルの読み込みに失敗しました')
        logger.fatal(e)

        Sysexits.exit(:config_error)
      end
      private :load_config

      # プラグインを読み込む
      # @return [void]
      def load_plugins
        loader = PluginsLoader.new(@config)
        @plugin_irc_adapters = loader.load_each(:IrcAdapter)
        @plugin_options = {}

        @plugin_irc_adapters.each do |adapter|
          @plugin_options[adapter] = {
            root_path: @root_path,
            plugin: @config.plugin_config[adapter.plugin_name]
          }
        end
      rescue => e
        print_error("プラグインの読み込みに失敗しました (#{e})")
        Sysexits.exit(:config_error)
      end
      private :load_plugins

      # IRC ボットを作り、設定して返す
      # @return [Cinch::Bot]
      def new_bot
        bot_config = @config.irc_bot
        bot = Cinch::Bot.new

        bot.configure do |c|
          c.server = bot_config['Host']
          c.port = bot_config['Port']
          c.password = bot_config['Password']
          # エンコーディングの既定値は UTF-8
          c.encoding = bot_config['Encoding'] || 'UTF-8'
          c.nick = bot_config['Nick']
          c.user = bot_config['User']
          c.realname = bot_config['RealName']
          # JOIN するチャンネルの既定値はなし（空の配列）
          c.channels = bot_config['Channels'] || []

          c.plugins.prefix = /^\./
          c.plugins.plugins = @plugin_irc_adapters
          c.plugins.options = @plugin_options
        end

        bot.loggers.level = @debug ? :debug : :info

        bot.on(:message, '.version') do |m|
          m.target.send("RGRB #{RGRB::VERSION}", true)
        end

        bot
      rescue => e
        print_error("IRC ボットの生成に失敗しました (#{e})")
        $stderr.puts('再度設定を確認してください')
        Sysexits.exit(:config_error)
      end
      private :new_bot

      # 新しい OptionParser を作り、設定して返す
      # @return [OptionParser]
      def new_opt_parser
        OptionParser.new do |opt|
          opt.summary_indent = ' ' * 2
          opt.summary_width = 24
          opt.banner = <<EOS
使用法: #{opt.program_name} [オプション]

汎用ボット RGRB - IRC ボット
EOS
          opt.version = RGRB::VERSION

          opt.separator('')
          opt.separator('オプション:')

          opt.on(
            '-c', '--config=CONFIG_ID',
            '設定 CONFIG_ID を読み込みます'
          ) do |config_id|
            @config_id = config_id
          end

          opt.on(
            '--debug',
            'デバッグモード。ログを冗長にします。'
          ) do
            @debug = true
          end
        end
      end
      private :new_opt_parser

      # 新しいロガーを作り、設定して返す
      # @return [Logger]
      def new_logger
        logger = Lumberjack::Logger.new($stdout)

        logger.progname = self.class.to_s
        logger.level = Lumberjack::Logger::INFO

        logger
      end
      private :new_logger
    end
  end
end
