# vim: fileencoding=utf-8

require 'cinch'
require 'uri'
require 'redis'

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
      end

      # NOTICE でジェネレート結果を返す
      def rg(m, tables_str)
        tables_str.split(' ').each do |table|
          result = get_value_from(table)
          message = result ?
            "rg[#{m.user.nick}]<#{table}>: #{result} ですわ☆" :
            "「#{table}」なんて表は見つからないのですわっ。"

          m.channel.notice message

          sleep 1
        end
      end

      private

      # 与えられた表名を使って DB から値を取得する
      def get_value_from(table)
        # テスト用：必ず「見つからない」
        nil
      end
    end
  end
end
