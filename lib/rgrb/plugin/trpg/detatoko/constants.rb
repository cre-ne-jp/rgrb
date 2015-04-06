# vim: fileencoding=utf-8


module RGRB
  module Plugin
    module Trpg
      module Detatoko
        # スキルランクを表す正規表現
        SR_RE = /(?:s|sr)(\d+)/
        # 固定値での四則演算を表す正規表現
        SOLID_RE = %r|([+*\-/])(\d+)|
        # フラグを指定した時の正規表現
        FLAG_RE = /@(\d+)/
        # コマンドのパターンの最後を表す正規表現
        END_RE = /(?:[\s　]|$)/
        # スタンス系統にマッチする正規表現
        STANCE_RE = /(?:敵視|宿命|憎悪|雲上|従属|不明|全部|[・＋\+])+/
      end
    end
  end
end
