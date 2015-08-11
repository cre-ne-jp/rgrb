require 'date'
require 'yaml'

module RGRB
  module Plugin
    module Trpg
      module Kancolle
        # 艦これRPGで使う各種決定表を表すクラス
        #
        # YAML から変換されたハッシュの構造に依存しないように
        # 抽象化する。
        class Table
          # 表のファイル名
          # @return [String]
          attr_reader :name
          # 表の日本語名
          # @return [String]
          attr_reader :name_ja
          # 表の掲載ルールブック
          # @return [String, nil]
          attr_reader :rulebook
          # 表の掲載ページ
          # @return [Fixnum, nil]
          attr_reader :page
          # 追加日
          # @return [Date, nil]
          attr_reader :added
          # 変更日
          # @return [Date, nil]
          attr_reader :modified

          # YAML を解析して Table オブジェクトに変換する
          # @param [String] yaml 表を表す YAML 文字列
          # @return [Table]
          def self.parse_yaml(yaml)
            data = YAML.load(yaml)

            name = data['Name']
            name_ja = data['Name-ja']
            values = data['Body']
            rulebook = data['Rulebook']
            page = data['Page'].to_i

            added, modified = %w(Added Modified).map do |key|
              value = data[key]

              case value
              when nil
                nil
              when Date
                value
              else
              Date.parse(value)
              end
            end

            new(
              name,
              values,
              name_ja: name_ja,
              rulebook: rulebook,
              page: page,
              added: added,
              modified: modified,
            )
          end

          # 新しい Table インスタンスを返す
          # @param [String] name 表名
          # @param [Array<String>] values 表の値の配列
          # @param [Hash] metadata メタデータ
          # @option metadata [String] :name_ja 表の日本語名
          # @option metadata [String] :rulebook 表の掲載ルールブック
          # @option metadata [Fixnum] :page 表の掲載ページ
          # @option metadata [Date] :added 追加日
          # @option metadata [Date] :modified 変更日
          def initialize(name, values, metadata)
            actual_metadata = {}.merge(metadata)

            @name = name
            @values = values

            @name_ja = actual_metadata[:name_ja]
            @rulebook = actual_metadata[:rulebook]
            @page = actual_metadata[:page]
            @added = actual_metadata[:added]
            @modified = actual_metadata[:modified]
          end

          # 表から値を 1 個取り出す
          # @param [Random] random 使用する乱数生成器
          def sample(random: Random::DEFAULT)
            "#{@values.sample(random: random)}"
          end
        end
      end
    end
  end
end
