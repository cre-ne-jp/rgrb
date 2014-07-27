# vim: fileencoding=utf-8

require 'cinch'
require 'uri'
require 'redis'

module RGRB
  module Plugin
    # ランダムジェネレータプラグイン
    class RandomGenerator
      include Cinch::Plugin

      # 基本的な結果書式
      # 例) rg[koi-chan]: ハートの6 ですわ☆
      RESULT_MESSAGE = 'rg[%s]: %sですわ☆'

      # Redis 接続用変数(インスタンス)
      #@redis = Redis.new

      # .rg にマッチ
      match /rg[ 　]+(.+)/, method: :rg

      def initialize(*args)
        @redis = Redis.new
      end

      # NOTICE で ジェネレート結果を返す
      def rg(m, command)
        return m.channel.notice(
	  "#{command} なんて表名は使っちゃダメですのっ"
	  ) unless command =~ /^[0-9A-Za-z_-]+$/
	return m.channel.notice(
          "#{command} なんて表はないのですわっ"
	  ) if @redis.hexists('command', command) == 0
	
	m.channel.notice RESULT_MESSAGE % m.user.nick, random_generator(command)
      end

      private

      # 与えられたコマンドを元にDBから結果を生成する
      def random_generator(command)
      end

    end
  end
end
