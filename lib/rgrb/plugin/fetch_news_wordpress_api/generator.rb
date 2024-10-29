# vim: fileencoding=utf-8

require 'time'
require 'uri'
require 'net/http'
require 'json'
require 'rgrb/plugin_base/generator'

module RGRB
  module Plugin
    # WordPress REST API から新規記事を取得するプラグイン
    module FetchNewsWordpressApi
      # 出力テキスト生成器
      class Generator
        include PluginBase::Generator

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
          @max_posts_per_check = config_data['MaxPostsPerCheck'] || 5

          self
        end

        # 記事を取得し、メッセージの配列として返す
        # @return [Array<String>]
        def cite_from_wordpress
          posts = get_request

          write_last_cited

          posts.map { |post| post_to_message(post) }
        end

        private

        # WordPress REST API から記事を取得する
        # 並べ替え等も取得時の条件で設定しておく
        # @return [Array]
        def get_request
          uri = URI('https://www.cre.ne.jp/wp-json/wp/v2/posts')
          uri.query = URI.encode_www_form({
            categories_exclude: '56',
            after: read_last_cited.strftime('%FT%T'),
            per_page: @max_posts_per_check
          })

          res = Net::HTTP.get_response(uri)
          JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
        end

        # 記事からメッセージを生成し、返す
        # @param [Hash] post 記事
        # @return [String]
        def post_to_message(post)
          "【お知らせ】#{post['title']['rendered']} (" \
            "#{Time.parse(post['date']).strftime('%F %T')}; " \
            "#{post['link']})"
        end

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

        # 最終引用日時を書き込む
        # @return [void]
        def write_last_cited
          File.open(@last_cited_path, 'w') do |f|
            f.puts(Time.now)
          end
        end
      end
    end
  end
end
