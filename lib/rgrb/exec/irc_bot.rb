# vim: fileencoding=utf-8

require 'cinch'
require 'optparse'
require 'sysexits'

require 'rgrb/version'
require 'rgrb/config'
require 'rgrb/plugin/keyword'
require 'rgrb/plugin/dice_roll'
require 'rgrb/plugin/random_generator'

module RGRB
  module Exec
    # IRC ボットの実行ファイルの処理を担うクラス
    class IRCBot
      # 設定ファイルの標準パス（相対パス）
      DEFAULT_CONFIG_PATH = 'config/rgrb.yaml'

      # 新しい RGRB::Exec::IRCBot インスタンスを返す
      # @param [String] rgrb_root_path RGRB のルートディレクトリの絶対パス
      # @param [Array<String>] argv コマンドライン引数の配列
      def initialize(rgrb_root_path, argv)
        @root_path = rgrb_root_path
        @argv = argv

        @config_path = "#{@root_path}/#{DEFAULT_CONFIG_PATH}"
        @opt = new_opt_parser
      end

      # プログラムを実行する
      # @return [void]
      def execute
        @opt.parse!(@argv)
        load_config
        bot = new_bot

        # シグナルを捕捉し、ボットを終了させる処理
        # trap 内で普通に bot.quit すると ThreadError が出るので
        # 新しい Thread で包む
        %i(INT TERM).each do |signal|
          Signal.trap(signal) do
            Thread.new do
              bot.quit
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
      # @return [void]
      # @todo ファイル名を指定して読み込めるようにする
      def load_config
        @config = RGRB::Config.load_yaml_file(@config_path)
      rescue => e
        print_error("設定ファイルの読み込みに失敗しました (#{e})")
        Sysexits.exit(:config_error)
      end
      private :load_config

      # IRC ボットを作り、設定して返す
      # @return [Cinch::Bot]
      def new_bot
        bot_config = @config.irc_bot
        rgrb_plugins = @config.plugins

        bot = Cinch::Bot.new
        bot.configure do |c|
          c.server = bot_config['Host']
          c.port = bot_config['Port']
          c.password = bot_config['Password']
          c.nick = bot_config['Nick']
          c.user = bot_config['User']
          c.realname = bot_config['RealName']

          c.plugins.prefix = /^\./
          c.plugins.plugins = rgrb_plugins
          c.plugins.options = Hash[
            rgrb_plugins.map do |plugin_class|
              [
                plugin_class,
                {
                  rgrb_root_path: @root_path,
                  rgrb_config: @config
                }
              ]
            end
          ]
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

汎用ダイスボット RGRB - IRC ボット
EOS
          opt.version = RGRB::VERSION

          opt.separator('')
          opt.separator('オプション:')

          opt.on(
            '-c',
            '--config=CONFIG_FILE',
            '設定ファイルとして CONFIG_FILE を読み込みます'
          ) do |config_file|
            @config_path = config_file
          end
        end
      end
      private :new_opt_parser
    end
  end
end
