# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # .help に対応するプラグイン
    class CreBotHelp
      include Cinch::Plugin

      # ヘルプメッセージ
      HELP_MESSAGE = <<EOS
クリエイターズネットワーク公式IRCボット
ご利用方法: http://www.cre.ne.jp/services/irc/bots
リファレンス: http://hiki.trpg.net/wiki/?RoleBot
EOS

      match(/help/, method: :help)

      # ヘルプメッセージを返す
      # @return [void]
      def help(m)
        m.target.notice(HELP_MESSAGE)
      end
    end
  end
end
