# vim: fileencoding=utf-8

require 'uri'
require 'rgrb/plugin_base/generator'

module RGRB
  module Plugin
    # キーワード検索プラグイン
    module Keyword
      # Keyword の出力テキスト生成器
      class Generator
        include PluginBase::Generator

        # cre.jp 検索ページの URL
        # %s には、URL エンコードされたキーワードが入る
        CRE_SEARCH_URL = 'https://log.irc.cre.jp/keywords/%s'

        # 新しい Keyword::Generator インスタンスを返す
        def initialize
          @amazon_search_url =
            'https://www.amazon.co.jp/gp/search?' \
            'ie=UTF8&keywords=%s'
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          amazon_associate_id = config_data['AmazonAssociateID'] || ''
          @amazon_search_url =
            'https://www.amazon.co.jp/gp/search?' \
            "ie=UTF8&tag=#{amazon_associate_id}&keywords=%s"

          self
        end

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
          url = @amazon_search_url % URI.encode_www_form_component(keyword)
          "Amazon.co.jp の商品一覧から #{url} をどうぞ♪"
        end
      end
    end
  end
end
