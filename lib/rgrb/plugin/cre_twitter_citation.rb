# vim: fileencoding=utf-8

require 'time'
require 'cinch'
require 'twitter'
require 'hugeurl'

module RGRB
  module Plugin
    # Twitter @cre_ne_jp 引用プラグイン
    class CreTwitterCitation
      include Cinch::Plugin

      # http://t.co/〜 の URL のパターン
      T_CO_PATTERN = %r{(?<!\w)(?=\w)http://t\.co/[0-9A-Za-z]+}

      def initialize(*args)
        super

        load_config

        # Twitter クライアント
        @twitter = new_twitter_client
        # 最終引用日時を記録するファイルのパス
        @last_cited_path = "#{config[:rgrb_root_path]}/data/" \
          'cre_twitter_citation/last_cited.txt'

        Timer(@check_interval, method: :cite_from_twitter).start
      end

      # ツイートを引用し、NOTICE する
      # @return [void]
      def cite_from_twitter
        last_cited = read_last_cited
        uncited_tweets = @twitter.user_timeline(
          @twitter_id,
          count: @max_tweets_per_check,
          include_rts: false
        ).select { |tweet| tweet.created_at > last_cited }
        write_last_cited

        uncited_tweets.sort_by { |tweet| tweet.created_at }.each do |tweet|
          url_expanded_text = tweet.full_text.gsub(T_CO_PATTERN) do |url|
            Hugeurl.get(url)
          end

          @channels_to_send.each do |channel_name|
            Channel(channel_name).safe_notice(
              "【お知らせ】#{url_expanded_text} (" \
                "#{tweet.created_at.strftime('%F %T')}; " \
                "#{tweet.url})"
            )

            sleep 1
          end
        end
      end

      # 最終引用日時を読み込む
      # @return [Time] 最終引用日時。
      #   読み込みに失敗した場合、UNIX エポック
      def read_last_cited
        File.open(@last_cited_path) do |f|
          Time.parse(f.gets)
        end
      rescue => e
        log(e.message, :exception, :error)
        Time.at(0)
      end
      private :read_last_cited

      # 最終引用日時を書き込む
      # @return [void]
      def write_last_cited
        File.open(@last_cited_path, 'w') do |f|
          f.puts(Time.now)
        end
      end
      private :write_last_cited

      # 設定を読み込む
      def load_config
        plugin_config = config[:rgrb_config].plugin_config(self.class)
        twitter_config = plugin_config['Twitter']

        @check_interval = plugin_config['CheckInterval']
        @max_tweets_per_check = plugin_config['MaxTweetsPerCheck']
        @channels_to_send = plugin_config['ChannelsToSend']
        @twitter_id = twitter_config['ID']

        @consumer_key = twitter_config['APIKey']
        @consumer_secret = twitter_config['APISecret']
        @access_token = twitter_config['AccessToken']
        @access_token_secret = twitter_config['AccessTokenSecret']
      end
      private :load_config

      # 新しい Twitter クライアントを返す
      def new_twitter_client
        Twitter::REST::Client.new do |config|
          config.consumer_key = @consumer_key
          config.consumer_secret = @consumer_secret
          config.access_token = @access_token
          config.access_token_secret = @access_token_secret
        end
      end
      private :new_twitter_client
    end
  end
end
