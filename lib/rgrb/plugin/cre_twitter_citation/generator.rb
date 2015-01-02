# vim: fileencoding=utf-8

require 'time'
require 'cgi/util'
require 'twitter'
require 'hugeurl'
require 'rgrb/plugin/configurable_generator'

module RGRB
  module Plugin
    # Twitter @cre_ne_jp 引用プラグイン
    module CreTwitterCitation
      # CreTwitterCitation の出力テキスト生成器
      class Generator
        include ConfigurableGenerator

        # http://t.co/〜 の URL のパターン
        T_CO_PATTERN = %r{(?<!\w)(?=\w)http://t\.co/[0-9A-Za-z]+}

        # RGRB のルートパスを設定する
        # @param [String] root_path RGRB のルートパス
        # @return [String] RGRB のルートパス
        def root_path=(root_path)
          super

          @last_cited_path = "#{@data_path}/last_cited.txt"

          root_path
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          twitter_config = config_data['Twitter']

          @max_tweets_per_check = config_data['MaxTweetsPerCheck']
          @twitter_id = config_data['ID']

          @consumer_key = twitter_config['APIKey']
          @consumer_secret = twitter_config['APISecret']
          @access_token = twitter_config['AccessToken']
          @access_token_secret = twitter_config['AccessTokenSecret']

          @twitter = new_twitter_client

          self
        end

        # ツイートを引用し、メッセージの配列として返す
        # @return [Array<String>]
        def cite_from_twitter
          last_cited = read_last_cited
          uncited_tweets = @twitter.user_timeline(
            @twitter_id,
            count: @max_tweets_per_check,
            include_rts: false
          ).select { |tweet| tweet.created_at > last_cited }
          write_last_cited

          uncited_tweets.sort_by { |tweet| tweet.created_at }.map do |tweet|
            tweet_to_message(tweet)
          end
        end

        # ツイートからメッセージを生成し、返す
        # @param [Twitter::Tweet] tweet ツイート
        # @return [String]
        def tweet_to_message(tweet)
          html_unescaped_text = CGI.unescapeHTML(tweet.full_text)
          url_expanded_text = html_unescaped_text.
            gsub(T_CO_PATTERN) { |url| Hugeurl.get(url) }

          # 日本時間のツイート時刻を求める
          # Tweet#created_at は frozen で変更不可なので
          # dup で複製してから設定する
          created_at_local = tweet.created_at.dup.localtime('+09:00')

          "【お知らせ】#{url_expanded_text} (" \
            "#{created_at_local.strftime('%F %T')}; " \
            "#{tweet.url})"
        end
        private :tweet_to_message

        # 最終引用日時を読み込む
        # @return [Time] 最終引用日時。
        #   読み込みに失敗した場合、UNIX エポック
        def read_last_cited
          File.open(@last_cited_path) do |f|
            Time.parse(f.gets)
          end
        rescue
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

        # 新しい Twitter クライアントを返す
        # @return [Twitter::REST::Client]
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
end
