# vim: fileencoding=utf-8

require 'rgrb/irc_plugin'

module RGRB
  module Plugin
    # CTCP 応答プラグイン
    module Ctcp
      # Ctcp の IRC アダプター
      class IrcAdapter
        include IrcPlugin

        set(plugin_name: 'Ctcp')
        ctcp(:clientinfo)
        ctcp(:version)
        ctcp(:time)
        ctcp(:ping)
        ctcp(:userinfo)
        ctcp(:source)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @userinfo = config_data['UserInfo'] || 'RGRB 稼働中'
          @valid_cmd = %w(CLIENTINFO VERSION TIME PING USERINFO SOURCE).sort
        end

        def ctcp_clientinfo(m)
          m.ctcp_reply(@valid_cmd.join(' '))
        end

        def ctcp_version(m)
          m.ctcp_reply("RGRB #{RGRB::VERSION}")
        end

        def ctcp_time(m)
          m.ctcp_reply(Time.now.strftime('%a %b %d %T %Y %Z'))
        end

        def ctcp_ping(m)
          m.ctcp_reply(m.ctcp_args.join(' '))
        end

        def ctcp_userinfo(m)
          m.ctcp_reply(@userinfo)
        end

        def ctcp_source(m)
          m.ctcp_reply('https://github.com/cre-ne-jp/rgrb')
        end
      end
    end
  end
end
