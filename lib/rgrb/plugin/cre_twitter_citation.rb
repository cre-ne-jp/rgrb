# vim: fileencoding=utf-8

require 'cinch'
require 'twitter'

module RGRB
  module Plugin
    # Twitter @cre_ne_jp 引用プラグイン
    class CreTwitterCitation
      include Cinch::Plugin

      INTERVAL = 30
      CHANNEL_TO_SEND = ''

      ACCOUNT = 'cre_ne_jp'
      CONSUMER_KEY = ''
      CONSUMER_SECRET = ''
      ACCESS_TOKEN = ''
      ACCESS_TOKEN_SECRET = ''

      def initialize(*args)
        super

        @twitter = Twitter::REST::Client.new do |config|
          config.consumer_key = CONSUMER_KEY
          config.consumer_secret = CONSUMER_SECRET
          config.access_token = ACCESS_TOKEN
          config.access_token_secret = ACCESS_TOKEN_SECRET
        end

        # 最後の引用日時
        # 初期化時は非常に前（UNIX エポック：1970 年）になるようにする
        @last_cited = Time.at(0)

        Timer(INTERVAL, method: :cite_from_twitter).start
      end

      def cite_from_twitter
        uncited_tweets = @twitter.user_timeline(
          ACCOUNT,
          count: 4, # 3 件 + 1
          include_rts: false
        ).select { |tweet| tweet.created_at > @last_cited }

        @last_cited = Time.now

        uncited_tweets.sort_by { |tweet| tweet.created_at }.each do |tweet|
          Channel(CHANNEL_TO_SEND).safe_notice(
            "お知らせ：#{tweet.full_text}"
          )
          sleep 1
        end
      end
    end
  end
end
