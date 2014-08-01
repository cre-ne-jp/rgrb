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
      match(/rg[ 　]+([-_0-9A-Za-z]+(?: +[-_0-9A-Za-z]+)*)/, method: :rg)

      def initialize(*args)
        super

        @rgrb_root_path = config[:rgrb_root_path]
        @redis_rg = Redis::Namespace.new('rg', redis: config[:redis])

        load_data
      end

      # NOTICE でジェネレート結果を返す
      # @return [void]
      def rg(m, tables_str)
        tables_str.split(' ').each do |table|
          result = get_value_from(table)
          message =
            if result
              "rg[#{m.user.nick}]<#{table}>: #{result} ですわ☆"
            else
              "rg[#{m.user.nick}]: 「#{table}」なんて表は見つからないのですわっ。"
            end

          m.channel.notice message

          sleep 1
        end
      end

      private

      # 与えられた表名を使って DB から値を取得する
      # @param [String] table 表名
      # @return [String]
      # @return [nil]
      def get_value_from(table)
        @redis_rg.srandmember(table)
      end

      # 表のデータを読み込む
      # @return [void]
      def load_data
        pattern = "#{@rgrb_root_path}/data/rg/*.txt"
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
