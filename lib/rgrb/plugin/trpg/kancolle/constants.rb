# vim: fileencoding=utf-8


module RGRB
  module Plugin
    module Trpg
      module Kancolle
        # 空白を表す正規表現
        SPACES_RE = /[ 　]+/
        # 艦娘の名前を表す正規表現
        KANMUSU_RE = /[a-z]/
        # 表名を表す正規表現
        TABLE_RE = /[-_0-9A-Za-z]+/
        # 表のリストを表す正規表現
        TABLES_RE = /(#{TABLE_RE}(?: +#{TABLE_RE})*)/o

        # 変数を表す正規表現
        VARIABLE_RE = /%%(#{TABLE_RE})%%/o
        # アラビア数字による数を表す正規表現
        NUM_RE = /[1-9]/
        NUMS_RE = /[1-9]\d*/
        # ダイスロールを表す正規表現
        BASICDICE_RE = /@@(#{NUMS_RE}*)d(#{NUMS_RE}*)@@/io
        # dxxロールを表す正規表現
        DXXDICE_RE = /@@d(#{NUM_RE}+)@@/io
      end
    end
  end
end
