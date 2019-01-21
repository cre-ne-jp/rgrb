# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/cre_bot_help/generator'

module RGRB
  module Plugin
    module CreBotHelp
      # CreBotHelp の Discord アダプター
      class DiscordAdapter
        include RGRB::DiscordPlugin
        include Util::Logging

        set(plugin_name: 'CreBotHelp')
        match(/help/, method: :help)

        # ヘルプメッセージを返す
        # @return [void]
        def help(m)
          log_incoming(m)
          m.send_message(Generator::HELP_MESSAGE)
        end
      end
    end
  end
end
