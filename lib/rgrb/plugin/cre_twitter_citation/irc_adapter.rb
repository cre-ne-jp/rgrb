# vim: fileencoding=utf-8

require 'rgrb/irc_plugin'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/cre_twitter_citation/generator'

module RGRB
  module Plugin
    # Twitter @cre_ne_jp 引用プラグイン
    module CreTwitterCitation
      # CreTwitterCitation の IRC アダプター
      class IrcAdapter
        include IrcPlugin
        include ConfigurableAdapter

        set(plugin_name: 'CreTwitterCitation')

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
