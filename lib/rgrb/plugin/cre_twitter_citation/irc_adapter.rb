# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/cre_twitter_citation/generator'
require 'rgrb/plugin/util/notice_multi_lines'

module RGRB
  module Plugin
    # Twitter @cre_ne_jp 引用プラグイン
    module CreTwitterCitation
      # CreTwitterCitation の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter
        include Util::NoticeMultiLines

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
          @channels_to_send.each do |channel_name|
            notice_multi_lines(
              @generator.cite_from_twitter,
              Channel(channel_name), 
              '',
              true
            )
          end
        end
      end
    end
  end
end
