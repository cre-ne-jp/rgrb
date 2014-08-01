# vim: fileencoding=utf-8

require 'optparse'
require 'redis'
require 'cinch'
require 'sysexits'

require 'rgrb/config'
require 'rgrb/plugin/keyword'
require 'rgrb/plugin/dice_roll'
require 'rgrb/plugin/random_generator'

module RGRB
  module Exec
    # IRC ボットの実行ファイルの処理を担うクラス
    class IRCBot
      # 新しい RGRB::Exec::IRCBot インスタンスを返す
      # @param [String] rgrb_root_path RGRB のルートディレクトリの絶対パス
      # @param [Array<String>] argv コマンドライン引数の配列
      def initialize(rgrb_root_path, argv)
        @root_path = rgrb_root_path
        @argv = argv
      end

      # プログラムを実行する
      # @return [void]
      def execute
        load_config
        prepare_redis_client
        bot = new_bot

        # シグナルを捕捉し、ボットを終了させる処理
        # trap 内で普通に bot.quit すると ThreadError が出るので
        # 新しい Thread で包む
        %i(INT TERM).each do |signal|
          Signal.trap(signal) do
            Thread.new do
              bot.quit
              @redis.flushdb
            end
          end
        end

        bot.start
      end

      private

      # エラーメッセージを表示する
      # @param [String] message エラーメッセージ
      # @return [void]
      def print_error(message)
        $stderr.puts "#{File.basename($PROGRAM_NAME, '.*')}: #{message}"
      end

      # 設定を読み込む
      # @return [void]
      # @todo ファイル名を指定して読み込めるようにする
      def load_config
        yaml_path = "#{@root_path}/config/rgrb.yaml"
        @config = RGRB::Config.load_yaml_file(yaml_path)
      rescue => e
        print_error "設定ファイルの読み込みに失敗しました (#{e})"
        Sysexits.exit :config_error
      end

      # Redis クライアントを準備する
      # @return [void]
      def prepare_redis_client
        redis_config = @config.redis
        @redis = Redis.new(
          host: redis_config['Host'],
          port: redis_config['Port'],
          db: redis_config['Database']
        )
        @redis.flushdb
      rescue => e
        print_error "Redis クライアントの生成に失敗しました (#{e})"
        $stderr.puts '再度設定を確認してください'
      end

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
                  redis: @redis
                }
              ]
            end
          ]
        end

        bot
      rescue => e
        print_error "IRC ボットの生成に失敗しました (#{e})"
        $stderr.puts '再度設定を確認してください'
        Sysexits.exit :config_error
      end
    end
  end
end
