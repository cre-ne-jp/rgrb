# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/cre_bot_help/generator'

module RGRB
  module Plugin
    module CreBotHelp
      # CreBotHelp の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'CreBotHelp')
        match(/help/, method: :help)

        # ヘルプメッセージを返す
        # @return [void]
        def help(m)
          m.target.notice(Generator::HELP_MESSAGE)
        end
      end
    end
  end
end
