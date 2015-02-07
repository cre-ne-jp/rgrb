# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/cre_twitter_citation/generator'

module RGRB
  module Plugin
    # Twitter @cre_ne_jp 引用プラグイン
    module CreTwitterCitation
      # CreTwitterCitation の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
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
          @generator.cite_from_twitter.each do |message|
            @channels_to_send.each do |channel_name|
              Channel(channel_name).safe_send(message, true)
              sleep(1)
            end
          end
        end
      end
    end
  end
end
