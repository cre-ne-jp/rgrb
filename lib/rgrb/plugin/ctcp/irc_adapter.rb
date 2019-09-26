# frozen_string_literal: true
# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'

module RGRB
  module Plugin
    # CTCP 応答プラグイン
    module Ctcp
      # Ctcp の IRC アダプター
      class IrcAdapter
        include PluginBase::IrcAdapter

        set(plugin_name: 'Ctcp')

        # 利用可能な CTCP コマンド
        AVAILABLE_COMMANDS = %w(CLIENTINFO VERSION TIME PING USERINFO SOURCE)
          .sort
          .freeze

        AVAILABLE_COMMANDS.each do |command|
          ctcp(command)
        end

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @userinfo = config_data['UserInfo'] || 'RGRB 稼働中'
        end

        def ctcp_clientinfo(m)
          ctcp_reply(m, AVAILABLE_COMMANDS.join(' '))
        end

        def ctcp_version(m)
          ctcp_reply(m, "RGRB #{RGRB::VERSION_WITH_COMMIT_ID}")
        end

        def ctcp_time(m)
          ctcp_reply(m, Time.now.strftime('%a, %d %b %Y %T %z'))
        end

        def ctcp_ping(m)
          ctcp_reply(m, m.ctcp_args.join(' '))
        end

        def ctcp_userinfo(m)
          ctcp_reply(m, @userinfo)
        end

        def ctcp_source(m)
          ctcp_reply(m, 'https://github.com/cre-ne-jp/rgrb')
        end

        private

        # CTCP 応答を返す
        # @param [Cinch::Message] m
        # @param [String] message 送信メッセージ
        # @return [void]
        def ctcp_reply(m, message)
          log_incoming(m)
          return if m.target.name == bot.nick

          m.ctcp_reply(message)
          log("<CTCP-reply to #{m.target.name}> #{message.inspect}", :outgoing, :info)
        end
      end
    end
  end
end
