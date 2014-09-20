# vim: fileencoding=utf-8

require 'cinch'
require 'uri'

module RGRB
  module Plugin
    # キーワード検索プラグイン
    class Keyword
      include Cinch::Plugin

      # cre.jp 検索ページの URL
      CRE_SEARCH_URL = 'http://cre.jp/search/?sw=%s'
      # Amazon.co.jp 検索ページの URL
      AMAZON_SEARCH_URL =
        'http://www.amazon.co.jp/gp/search?' \
        'ie=UTF8&tag=koubou-22&keywords=%s'

      # .k にマッチ
      match(/k[ 　]+(.+)/, method: :cre_search)
      # .a にマッチ
      match(/a[ 　]+(.+)/, method: :amazon_search)

      # NOTICE で cre.jp 検索ページを返す
      # @return [void]
      def cre_search(m, keyword)
        url = CRE_SEARCH_URL % URI.encode_www_form_component(keyword)
        m.target.notice("キーワード一覧の #{url} をどうぞ♪")
      end

      # NOTICE で Amazon.co.jp 検索ページを返す
      # @return [void]
      def amazon_search(m, keyword)
        url = AMAZON_SEARCH_URL % URI.encode_www_form_component(keyword)
        m.target.notice("Amazon.co.jp の商品一覧から #{url} をどうぞ♪")
      end
    end
  end
end
