# vim: fileencoding=utf-8

require 'rgrb/plugin/trpg/detatoko/gamedatas'

module RGRB
  module Plugin
    module Trpg
      module Detatoko
        class IrcAdapter
          # スキルランクを表す正規表現
          SR_RE = /(?:s|sr)(\d+)/
          # 固定値での四則演算を表す正規表現
          SOLID_RE = %r|([+*\-/])(\d+)|
          # フラグを指定した時の正規表現
          FLAG_RE = /@(\d+)/
          # 1行キャラシ用IDを表す正規表現
          LCSID_RE = /(\d+|title)/
          LCSIDS_RE = /(#{LCSID_RE}(?: +#{LCSID_RE})*)/
          # コマンドのパターンの最後を表す正規表現
          END_RE = /(?:[\s　]|$)/
          # スタンス系統にマッチする正規表現
          STANCE_RE = /(?:#{Generator::STANCES.keys.join('|')}|全部|[・＋\+])+/
        end
      end
    end
  end
end
