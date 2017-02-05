# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/keyword/generator'

module RGRB
  module Plugin
    module Keyword
      # Keyword の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::Logging
        include ConfigurableAdapter

        set(plugin_name: 'Keyword')
        match(/(k|a)[ 　]+(.+)/, method: :search)

        def initialize(*args)
          super
          prepare_generator
        end

        # キーワードで検索する
        # @param [Cinch::Message] m
        # @param [String] site_code 検索するウェブサイト
        # @param [String] keyword キーワード
        # @return [void]
        def search(m, site_code, keyword)
          log_incoming(m)

          message = case(site_code)
          when 'k'
            @generator.cre_search(keyword)
          when 'a'
            @generator.amazon_search(keyword)
          end

          m.target.send(message, true)
          log_notice(m.target, message)
        end
      end
    end
  end
end
