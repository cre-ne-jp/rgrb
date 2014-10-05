# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/keyword/generator'

module RGRB
  module Plugin
    module Keyword
      # Keyword の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'Keyword')
        match(/k[ 　]+(.+)/, method: :cre_search)
        match(/a[ 　]+(.+)/, method: :amazon_search)

        def initialize(*args)
          super

          @generator = Generator.new
        end

        # NOTICE で cre.jp 検索ページを返す
        # @return [void]
        def cre_search(m, keyword)
          m.target.notice(@generator.cre_search(keyword))
        end

        # NOTICE で Amazon.co.jp 検索ページを返す
        # @return [void]
        def amazon_search(m, keyword)
          m.target.notice(@generator.amazon_search(keyword))
        end
      end
    end
  end
end
