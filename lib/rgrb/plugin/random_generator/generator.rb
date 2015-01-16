# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/table'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/circular_reference'

module RGRB
  module Plugin
    # ランダムジェネレータプラグイン
    module RandomGenerator
      # RandomGenerator の出力テキスト生成器
      class Generator
        include ConfigurableGenerator

        def initialize
          super

          @ramdom = Random.new
        end

        # プラグインの設定を行う
        #
        # ランダムジェネレータでは、データを読み込む。
        def configure(*)
          super

          load_data("#{@data_path}/*.yaml")

          self
        end

        # 表からランダムに選んだ結果を返す
        # @param [String] table 表名
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        # @raise [CircularReference] 循環参照が起こった場合
        def rg(table)
          replace_var_with_value(get_value_from(table), table)
        end

        # 表から値を取得して返す
        # @param [String] table_name 表名
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        def get_value_from(table_name)
          fail(TableNotFound, table_name) unless @table[table_name]

          @table[table_name].sample(random: @random)
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
          @table = Hash[
            Dir.glob(glob_pattern).map do |path|
              yaml = File.read(path, encoding: 'UTF-8')
              table = Table.parse_yaml(yaml)

              [table.name, table]
            end
          ]
        end

        private :load_data
      end
    end
  end
end
