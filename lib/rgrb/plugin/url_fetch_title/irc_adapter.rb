# vim: fileencoding=utf-8

require 'cinch'
require 'uri'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/url_fetch_title/generator'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module UrlFetchTitle
      # UrlFetchTitle の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter
        include Util::Logging

        set(plugin_name: 'UrlFetchTitle')

        listen_to(:privmsg, method: :fetch_title)

        def initialize(*args)
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
              message = @generator.fetch_title(url)
              m.target.send(message, true)
              log_notice(m.target, message)
            end
          end
        end
      end
    end
  end
end
