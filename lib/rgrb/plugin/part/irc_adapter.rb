# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    module Part
      # Part の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'Part')
        match(/part/, method: :part)
        match(/part-(\w+)/, method: :part)

        def initialize(*args)
          super

          config_data = config[:plugin]
          @part_message = config_data['PartMessage']
        end

        # コマンドを発言されたらそのチャンネルから退出する
        # @return [void]
        def part(m, nick = nil)
          if nick == m.bot.to_s || nick == nil
            Channel(m.channel).part(@part_message)
          end
        end
      end
    end
  end
end
