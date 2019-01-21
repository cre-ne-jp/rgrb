# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/keyword/generator'

module RGRB
  module Plugin
    module Keyword
      # Keyword の Discord アダプター
      class DiscordAdapter
        include RGRB::DiscordPlugin
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
          message = case(site_code)
          when 'k'
            @generator.cre_search(keyword)
          when 'a'
            @generator.amazon_search(keyword)
          end

          m.send_message(message)
        end
      end
    end
  end
end
