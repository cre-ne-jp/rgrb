# vim: fileencoding=utf-8

require 'uri'

module RGRB
  module Plugin
    # キーワード検索プラグイン
    module Keyword
      # Keyword の出力テキストの生成器
      class Generator
        # cre.jp 検索ページの URL
        CRE_SEARCH_URL = 'http://cre.jp/search/?sw=%s'
        # Amazon.co.jp 検索ページの URL
        AMAZON_SEARCH_URL =
          'http://www.amazon.co.jp/gp/search?' \
          'ie=UTF8&tag=koubou-22&keywords=%s'

        # キーワードに対応した cre.jp 検索ページの URL を含む文章を返す
        # @return [String]
        def cre_search(keyword)
          url = CRE_SEARCH_URL % URI.encode_www_form_component(keyword)
          "キーワード一覧の #{url} をどうぞ♪"
        end

        # キーワードに対応した Amazon.co.jp 検索ページの URL
        # を含む文章を返す
        # @return [String]
        def amazon_search(keyword)
          url = AMAZON_SEARCH_URL % URI.encode_www_form_component(keyword)
          "Amazon.co.jp の商品一覧から #{url} をどうぞ♪"
        end
      end
    end
  end
end
