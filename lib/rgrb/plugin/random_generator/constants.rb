# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module RandomGenerator
      # 空白を表す正規表現
      SPACES_RE = /[ 　]+/
      # 表名を表す正規表現
      TABLE_RE = /[-_0-9A-Za-z]+/
      # 表のリストを表す正規表現
      TABLES_RE = /(#{TABLE_RE}(?: +#{TABLE_RE})*)/o
      # 変数を表す正規表現
      VARIABLE_RE = /%%(#{TABLE_RE})%%/o
    end
  end
end
