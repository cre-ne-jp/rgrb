# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/keyword/generator'

module RGRB
  module Plugin
    module Keyword
      # Keyword の Discord アダプター
      class DiscordAdapter
        include DiscordPlugin

        set(plugin_name: 'Keyword')
        match(/(k|a)[ 　]+(.+)/, method: :search)

        def initialize(*args)
          super
          prepare_generator
        end

        # キーワードで検索する
        # @param [Discordrb::Events::MessageEvent] m
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

          send_channel(m.channel, message)
        end
      end
    end
  end
end
