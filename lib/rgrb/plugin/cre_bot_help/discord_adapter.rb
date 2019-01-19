# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/cre_bot_help/generator'
require 'rgrb/plugin/util/notice_multi_lines'

module RGRB
  module Plugin
    module CreBotHelp
      # CreBotHelp の Discord アダプター
      class DiscordAdapter
        include RGRB::DiscordPlugin
        include Util::NoticeMultiLines

        set(plugin_name: 'CreBotHelp')
        match(/help/, method: :help)

        # ヘルプメッセージを返す
        # @return [void]
        def help(m)
puts('call help')
          log_incoming(m)
          notice_multi_messages(Generator::HELP_MESSAGE, m.channel)
        end
      end
    end
  end
end
