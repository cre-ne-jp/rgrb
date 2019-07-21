# vim: fileencoding=utf-8

require 'uri'
require 'rgrb/irc_plugin'
require 'rgrb/plugin/url_fetch_title/generator'

module RGRB
  module Plugin
    module UrlFetchTitle
      # UrlFetchTitle の IRC アダプター
      class IrcAdapter
        include IrcPlugin

        set(plugin_name: 'UrlFetchTitle')

        listen_to(:privmsg, method: :fetch_title)

        def initialize(*)
          super

          prepare_generator
        end

        # NOTICE でページのタイトルを返す
        # @return [void]
        def fetch_title(m)
          urls = URI.extract(m.message, %w(http https))
          unless urls.empty?
            log_incoming(m)

            urls.each do |url|
              send_notice(m.target, @generator.fetch_title(url))
            end
          end
        end
      end
    end
  end
end
