# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/cre_bot_help/generator'

module RGRB
  module Plugin
    module CreBotHelp
      # CreBotHelp の Discord アダプター
      class DiscordAdapter
        include RGRB::DiscordPlugin

        set(plugin_name: 'CreBotHelp')
        match(/help/, method: :help)

        # ヘルプメッセージを返す
        # @return [void]
        def help(m)
          log_incoming(m)
          send_channel(m.channel, Generator::HELP_MESSAGE)
        end
      end
    end
  end
end
