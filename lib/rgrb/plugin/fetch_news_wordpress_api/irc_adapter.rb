# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin/fetch_news_wordpress_api/generator'

module RGRB
  module Plugin
    # WordPress REST API から新規記事を取得するプラグイン
    module FetchNewsWordpressApi
      # IRC アダプター
      class IrcAdapter
        include PluginBase::IrcAdapter

        set(plugin_name: 'FetchNewsWordpressApi')

        def initialize(*args)
          super

          config_data = config[:plugin]
          @check_interval = config_data['CheckInterval']
          @channels_to_send = config_data['ChannelsToSend']

          prepare_generator
          Timer(@check_interval, method: :cite_from_twitter).start
        end

        # ツイートを引用し、NOTICE する
        # @return [void]
        def cite_from_twitter
          send_notice(@channels_to_send, @generator.cite_from_twitter, '', true)
        end
      end
    end
  end
end
