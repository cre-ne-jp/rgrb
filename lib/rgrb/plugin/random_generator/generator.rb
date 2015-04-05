# vim: fileencoding=utf-8

require 'lumberjack'

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/table'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/private_table'
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
          @logger = Lumberjack::Logger.new(
            STDOUT, progname: self.class.to_s
          )
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
          replace_var_with_value(get_value_from(table, true), table)
        end

        def desc(table_name)
          check_existence_of(table_name)

          @table[table_name].description
        end

        # 指定した表の説明を返す
        # @param [String] table_name 表名
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        def info(table_name)
          check_existence_of(table_name)

          mes = "#{table_name}は、" \
            "#{@table[table_name].jadded}に" \
            "#{@table[table_name].author}さんによって追加されましたの。"
          unless @table[table_name].jmodified == nil
            mes = mes \
              + "最後に更新されたのは" \
                "#{@table[table_name].jmodified}" \
                "ですわ。"
          end

          mes + "#{@table[table_name].description}"
        end

        # 表から値を取得して返す
        # @param [String] table_name 表名
        # @param [Boolean] root 最初に参照する表の場合 true にする
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        def get_value_from(table_name, root = false)
          check_existence_of(table_name)
          check_permission_of(table_name) if root

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
          @table = {}

          Dir.glob(glob_pattern).each do |path|
            begin
              yaml = File.read(path, encoding: 'UTF-8')
              table = Table.parse_yaml(yaml)

              @table[table.name] = table
            rescue => e
              @logger.error("データファイル #{path} の読み込みに失敗しました")
              @logger.error(e)
            end
          end
        end
        private :load_data

        # 表が存在するかどうかを調べる
        # @return [String] table_name 表名
        # @return [true] 表が存在する場合
        # @raise [TableNotFound] 表が存在しない場合
        def check_existence_of(table_name)
          fail(TableNotFound, table_name) unless @table.key?(table_name)

          true
        end
        private :check_existence_of

        def check_permission_of(table_name)
          fail(PrivateTable, table_name) unless @table[table_name].public?
        end
        private :check_permission_of
      end
    end
  end
end
