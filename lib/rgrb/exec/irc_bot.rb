require 'optparse'
require 'cinch'

require 'rgrb/plugin/hello'
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
        bot = Cinch::Bot.new do
          configure do |c|
            # c.server = '' # IRC サーバ
            # c.port = 6667
            # c.password = '' # パスワード
            c.nick = c.user = 'rgrb_cinch'
            c.realname = '汎用ダイスボット RGRB'

            c.plugins.plugins = [
              RGRB::Plugin::Hello,
              RGRB::Plugin::Keyword,
              RGRB::Plugin::DiceRoll,
              RGRB::Plugin::RandomGenerator
            ]
            c.plugins.prefix = /^\./
          end
        end

        bot.start
      end
    end
  end
end