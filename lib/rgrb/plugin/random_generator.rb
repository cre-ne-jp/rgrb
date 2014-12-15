# vim: fileencoding=utf-8

require 'cinch'
require 'yaml'

require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/circular_reference'

module RGRB
  module Plugin
    # ランダムジェネレータプラグインのクラス
    class RandomGenerator
      include Cinch::Plugin

      # 表名を表す正規表現
      TABLE_RE = /[-_0-9A-Za-z]+/
      # 変数を表す正規表現
      VARIABLE_RE = /%%(#{TABLE_RE})%%/o

      # .rg にマッチ
      match(/rg[ 　]+(#{TABLE_RE}(?: +#{TABLE_RE})*)/o, method: :rg)

      def initialize(*args)
        super

        load_data("#{config[:rgrb_root_path]}/data/rg/*.yaml")
      end

      # NOTICE でジェネレート結果を返す
      # @return [void]
      def rg(m, tables_str)
        header = "rg[#{m.user.nick}]"

        tables_str.split(' ').each do |table|
          body =
            begin
              result = replace_var_with_value(get_value_from(table),
                                              table => true)
              "<#{table}>: #{result} ですわ☆"
            rescue TableNotFound => not_found
              ": 「#{not_found.table}」なんて表は見つからないのですわっ。"
            rescue CircularReference => circular_reference
              ": 表「#{circular_reference.table}」で循環参照が起こりました。" \
                '#cre でご報告ください。'
            end
          m.target.notice(header + body)

          sleep(1)
        end
      end

      # 表から値を取得して返す
      # @param [String] table_name 表名
      # @return [String]
      # @raise [TableNotFound] 表が見つからなかった場合
      def get_value_from(table_name)
        fail(TableNotFound, table_name) unless @table[table_name]

        @table[table_name]['Body'].sample
      end

      private :get_value_from

      # 変数を表から取得した値に置換して返す
      # @param [String] str 置換対象の文字列
      # @param [String] root_table 値を取得した最初の表の名前
      # @raise [CircularReference] 循環参照が起こった場合
      # @return [String]
      def replace_var_with_value(str, root_table)
        getting = { root_table => true }

        while VARIABLE_RE === str
          # この段階で置換する変数の名前を格納する配列
          variables = []

          str = str.gsub(VARIABLE_RE) do
            table = Regexp.last_match(1)
            fail(CircularReference, table) if getting[table]

            variables << table

            get_value_from(table)
          end

          # hiragana2 等同じ名前の変数が含まれているときに
          # 循環参照と判断されないように
          # 最後に取得中のフラグを立てる
          variables.uniq.each do |variable|
            getting[variable] = true
          end
        end

        str
      end

      private :replace_var_with_value

      # 表のデータを読み込む
      # @param [String] glob_pattern データファイル名のパターン
      # @return [void]
      def load_data(glob_pattern)
        # 表を格納するハッシュ
        @table = {}

        Dir.glob(glob_pattern) do |path|
          name = File.basename(path, '.yaml')

          @table[name] = YAML.load_file(path)

#          File.open(path, 'r:UTF-8') do |f|
#            f.each_line do |line|
#              @table[name] = [] unless @table[name]
#              @table[name] << line.chomp
#            end
#          end
        end
      end

      private :load_data
    end
  end
end
