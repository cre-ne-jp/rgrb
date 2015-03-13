# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Detatoko
      # コマンドのパターンの最後を表す正規表現
      END_RE = /(?:[\s　]|$)/

      # 表名を表す正規表現
      TABLE_RE = /[-_0-9A-Za-z]+/
      # 表のリストを表す正規表現
      TABLES_RE = /(#{TABLE_RE}(?: +#{TABLE_RE})*)/o
      # 変数を表す正規表現
      VARIABLE_RE = /%%(#{TABLE_RE})%%/o
    end
  end
end
