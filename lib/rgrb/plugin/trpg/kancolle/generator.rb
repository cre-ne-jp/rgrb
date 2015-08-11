# vim: fileencoding=utf-8

require 'lumberjack'

require 'rgrb/plugin/dice_roll/generator'
require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/trpg/kancolle/constants'
require 'rgrb/plugin/trpg/kancolle/table'
require 'rgrb/plugin/trpg/kancolle/table_not_found'

module RGRB
  module Plugin
    module Trpg
      # システム別専用プラグイン「艦これRPG」
      module Kancolle
        # Kancolle の出力テキスト生成器
        class Generator
          include ConfigurableGenerator

          def initialize
            super

            @random = Random.new
            @dice_roll_generator = DiceRoll::Generator.new
            @table = {}
            @kanmusu = {}

            @logger = Lumberjack::Logger.new(
              $stdout, progname: self.class.to_s
            )
          end

          def configure(*)
            super

            load_tables("#{@data_path}/tables/*.yaml")
#            load_kanmusu("#{@data_path}/kanmusu/*.yaml")

            self
          end

          # 艦娘の名前を一つ選びます
          # @return [String]
          def kanmusu
            header = "艦娘: "

          end

          # 指定された艦娘のリアクション表を振ります
          # @param [String] kanmusu
          # @return [String]
          def kanmusu_reaction(kanmusu)
          end

          # イベント表や決定表などを振ります
          # @param [String] table 表名
          # @return [String]
          def table_random(table)
            replace_var_with_value(get_value_from(table, true), table)
          end

          # 表名から日本語名を調べる
          # @param [String] table_name 表名
          # @return [String]
          def table_name_ja(table_name)
            @table[table_name].name_ja
          end

          # 表から値を取得して返す
          # @param [String] table_name 表名
          # @param [Boolean] root 最初に参照する表の場合 true にする
          # @return [String]
          # @raise [TableNotFound] 表が見つからなかった場合
          def get_value_from(table_name, root = false)
            check_existence_of(table_name)

            @table[table_name].sample(random: @random)
          end
          private :get_value_from

          # 変数を表から取得した値に置換して返す
          # @param [String] str 置換対象の文字列
          # @param [String] root_table 値を取得した最初の表の名前
          # @return [String]
          def replace_var_with_value(str, root_table)
            get_count = { root_table => 1 }
            get_count.default = 0

            # 他の表を参照・埋め込み
            while VARIABLE_RE === str
              # この段階で置換する変数の名前を格納する配列
              variables = []

              str = str.gsub(VARIABLE_RE) do
                table = Regexp.last_match(1)

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

            # ダイスロールの埋め込み
            while BASICDICE_RE === str
              str = str.gsub(BASICDICE_RE) do
                rolls, sides = Regexp.last_match[1..2]
                @dice_roll_generator.dice_roll(rolls.to_i, sides.to_i).sum
              end
            end
            
            # dXX ロールの埋め込み
            while DXXDICE_RE === str
              str = str.gsub(DXXDICE_RE) do
                @dice_roll_generator.dxx_roll(Regexp.last_match(1)).sort.join
              end
            end

            str
          end

          # 表のデータを読み込む
          # @param [String] glob_pattern データファイル名のパターン
          # @return [void]
          def load_tables(glob_pattern)
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
          private :load_tables

          # 艦娘のデータを読み込む
          # @param [String] glob_pattern データファイル名のパターン
          # @return [void]
#          def load_kanmusu(glob_pattern)
#            Dir.glob(glob_pattern).each do |path|
#              begin
#                yaml = File.read(path, encoding: 'UTF-8')
#                kanmusu = Kanmusu.parse_yaml(yaml)
#
#                @kanmusu[kanmusu.name] = kanmusu
#              rescue => e
#                @logger.error("データファイル #{path} の読み込みに失敗しました")
#                @logger.error(e)
#              end
#            end
#          end
#          private :load_kanmusu

          # 表が存在することを確かめる
          # @return [String] table_name 表名
          # @return [true] 表が存在する場合
          # @raise [TableNotFound] 表が存在しない場合
          def check_existence_of(table_name)
            fail(TableNotFound, table_name) unless @table.key?(table_name)

            true
          end
          private :check_existence_of
        end
      end
    end
  end
end
