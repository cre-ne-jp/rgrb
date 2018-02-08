# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/anti_spam/generator'

module RGRB
  module Plugin
    module AntiSpam
      # AntiSpam の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::Logging
        include ConfigurableAdapter

        set(plugin_name: 'AntiSpam')
        listen_to(:join, method: :join)
        listen_to(:leaving, method: :leaving)
        listen_to(:privmsg, method: :privmsg)
        listen_to(:connect, method: :connect)
        match('check', method: :check)

        def initialize(*args)
          super
          prepare_generator
        end

        # (自身を含め)誰かがチャンネルに参加したとき、その情報を記録する
        # @param [Cinch::Message] m
        # @return [void]
        def join(m)
          log_incoming(m)
          pp m
          @generator.join(m)
        end

        # (自身を含め)誰かがチャンネルから退出したとき、その情報を記録する
        # @param [Cinch::Message] m
        # @param [Cinch::User] user
        # @return [void]
        def leaving(m, user)
          log_incoming(m)
          @generator.leaving(m)
        end

        # 参加しているチャンネルの発言を監視する
        # @param [Cinch::Message] m
        # return [void]
        def privmsg(m)
          log_incoming(m)
          @generator.privmsg(m)
        end

        def connect(m)
          sleep 1
        end

        def check(m)
          @generator.check
        end
      end
    end
  end
end
