# vim: fileencoding=utf-8

require 'cinch'
require 'uri'
require 'redis'
require 'redis-namespace'

module RGRB
  module Plugin
    # ランダムジェネレータプラグイン
    class RandomGenerator
      include Cinch::Plugin

      # .rg にマッチ
      match /rg[ 　]+([-_0-9A-Za-z]+(?: +[-_0-9A-Za-z]+)*)/, method: :rg

      def initialize(*args)
        super

        @redis = Redis.new
        @redis_rg = Redis::Namespace.new('rg', redis: @redis)

        load_data
      end

      # NOTICE でジェネレート結果を返す
      def rg(m, tables_str)
        tables_str.split(' ').each do |table|
          result = get_value_from(table)
          message = result ?
            "rg[#{m.user.nick}]<#{table}>: #{result} ですわ☆" :
            "rg[#{m.user.nick}]: 「#{table}」なんて表は見つからないのですわっ。"

          m.channel.notice message

          sleep 1
        end
      end

      private

      # 与えられた表名を使って DB から値を取得する
      def get_value_from(table)
        @redis_rg.srandmember(table)
      end

      def load_data
        @redis.flushdb

        pattern = "#{File.expand_path('../../../data/rg', File.dirname(__FILE__))}/*.txt"
        Dir.glob(pattern) do |path|
          key = File.basename(path, '.txt')

          File.open(path, 'r:UTF-8') do |f|
            f.each_line do |line|
              @redis_rg.sadd(key, line.chomp)
            end
          end
        end
      end
    end
  end
end
