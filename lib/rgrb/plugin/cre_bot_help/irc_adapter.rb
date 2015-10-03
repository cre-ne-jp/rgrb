# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/cre_bot_help/generator'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/util/notice_multi_lines'

module RGRB
  module Plugin
    module CreBotHelp
      # CreBotHelp の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::Logging
        include Util::NoticeMultiLines

        set(plugin_name: 'CreBotHelp')
        match(/help/, method: :help)

        # ヘルプメッセージを返す
        # @return [void]
        def help(m)
          log_incoming(m)
          notice_multi_messages(Generator::HELP_MESSAGE, m.channel)
        end
      end
    end
  end
end
