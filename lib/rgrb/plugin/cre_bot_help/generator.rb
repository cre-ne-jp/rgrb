# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # .help に対応するプラグイン
    module CreBotHelp
      # CreBotHelp の出力テキスト生成器
      class Generator
        # ヘルプメッセージ
        HELP_MESSAGE = <<EOS
クリエイターズネットワーク公式IRCボット
ご利用方法: http://www.cre.ne.jp/services/irc/bots
RGRB独自コマンド一覧: http://www.cre.ne.jp/services/irc/bots/rgrb
EOS
      end
    end
  end
end
