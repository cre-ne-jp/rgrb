# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Bcdice
      # 空白の連続を示す正規表現
      SPACES_RE = /[\s　]+/o

      # ダイスコマンドを示す正規表現
      DICE_COMMAND_RE = %r{[-+*/()<>=\[\].@\w]+}
      # ゲームタイトルを示す正規表現
      GAME_TITLE_RE = /[\x21-\x7E]+/

      # BCDice呼び出しの正規表現
      BCDICE_RE = /#{SPACES_RE}(#{DICE_COMMAND_RE})(?:#{SPACES_RE}(#{GAME_TITLE_RE}))?\z/o
    end
  end
end
