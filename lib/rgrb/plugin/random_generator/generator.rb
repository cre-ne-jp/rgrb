# vim: fileencoding=utf-8

require 'rgrb/plugin_base/generator'
require 'rgrb/plugin/random_generator/constants'
require 'rgrb/plugin/random_generator/table'
require 'rgrb/plugin/random_generator/table_not_found'
require 'rgrb/plugin/random_generator/private_table'

module RGRB
  module Plugin
    # ランダムジェネレータプラグイン
    module RandomGenerator
      # RandomGenerator の出力テキスト生成器
      class Generator
        include PluginBase::Generator

        # 循環参照と見做される同一表参照回数の閾値
        CIRCULAR_REFERENCE_THRESHOLD = 10

        def initialize
          super

          @random = Random.new
        end

        # プラグインの設定を行う
        #
        # ランダムジェネレータでは、データを読み込む。
        #
        # @return [self]
        def configure(config_data)
          super

          load_data!("#{@data_path}/**/*.yaml")

          self
        end

        # 表からランダムに選んだ結果を返す
        # @param [String] table 表名
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        # @note 循環参照を CIRCULAR_REFERENCE_THRESHOLD
        #   まで許容するようになった
        def rg(table)
          replace_var_with_value(get_value_from(table, true), table)
        end

        # 指定した表の概要を返す
        # @param [String] table_name 表名
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        def desc(table_name)
          check_existence_of(table_name)

          @table[table_name].description
        end

        # 指定した表の詳細な説明を返す
        # @param [String] table_name 表名
        # @return [String]
        # @raise [TableNotFound] 表が見つからなかった場合
        def info(table_name)
          check_existence_of(table_name)

          added_and_author =
            "「#{table_name}」の作者は" \
              " #{@table[table_name].author} さんで、" \
              "#{japanese_date(@table[table_name].added)} に" \
              "追加されましたの。"
          modified_value = @table[table_name].modified
          modified =
            if modified_value
              "最後に更新されたのは" \
                " #{japanese_date(modified_value)} " \
                "ですわ。"
            else
              ''
            end
          description = @table[table_name].description

          "#{added_and_author}#{modified}#{description}"
        end

        # 表を一覧にして返す
        # @return [Array]
        def list
          @table.select do |key, value|
            value.public?
          end.keys.sort
        end

        # 表のデータを読み込む
        # @param [String] glob_pattern データファイル名のパターン
        # @return [void]
        def load_data!(glob_pattern)
          # 表を格納するハッシュ
          @table = {}

          Dir.glob(glob_pattern).each do |path|
            begin
              yaml = File.read(path, encoding: 'UTF-8')
              table = Table.parse_yaml(yaml)

              @table[table.name] = table
            rescue => e
              logger.error("データファイル #{path} の読み込みに失敗しました")
              logger.error(e)
            end
          end
        end

        private

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

        # 変数を表から取得した値に置換して返す
        # @param [String] str 置換対象の文字列
        # @param [String] root_table 値を取得した最初の表の名前
        # @return [String]
        def replace_var_with_value(str, root_table)
          get_count = { root_table => 1 }
          get_count.default = 0

          while VARIABLE_RE === str
            # この段階で置換する変数の名前を格納する配列
            variables = []

            str = str.gsub(VARIABLE_RE) do
              table = Regexp.last_match(1)

              if get_count[table] >= CIRCULAR_REFERENCE_THRESHOLD
                # 同一表の参照上限に到達したので、打ち切る
                logger.warn("参照上限到達: #{table}")
                next '(...)'
              end

              variables << table

              get_value_from(table)
            end

            # hiragana2 等同じ名前の変数が含まれているときに
            # 循環参照と判断されないように
            # 最後に取得中のフラグを立てる
            variables.uniq.each do |variable|
              get_count[variable] += 1
            end
          end

          str
        end

        # 表が存在することを確かめる
        # @return [String] table_name 表名
        # @return [true] 表が存在する場合
        # @raise [TableNotFound] 表が存在しない場合
        def check_existence_of(table_name)
          fail(TableNotFound, table_name) unless @table.key?(table_name)

          true
        end

        # 表が公開されていることを確かめる
        # @return [String] table_name 表名
        # @return [true] 表が公開されている場合
        # @raise [PrivateTable] 表が公開されていない場合
        def check_permission_of(table_name)
          fail(PrivateTable, table_name) unless @table[table_name].public?

          true
        end

        # 日付の日本語表記を返す
        # @param [Date, DateTime] date 日付
        # @return [String]
        def japanese_date(date)
          "#{date.year}年#{date.month}月#{date.day}日"
        end
      end
    end
  end
end
