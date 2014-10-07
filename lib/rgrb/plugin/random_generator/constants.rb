# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module RandomGenerator
      # 表名を表す正規表現
      TABLE_RE = /[-_0-9A-Za-z]+/
      # 変数を表す正規表現
      VARIABLE_RE = /%%(#{TABLE_RE})%%/o
    end
  end
end
