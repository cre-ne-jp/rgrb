require 'date'
require 'yaml'

module RGRB
  module Plugin
    module RandomGenerator
      # ランダムジェネレータの表を表すクラス
      #
      # YAML から変換されたハッシュの構造に依存しないように
      # 抽象化する。
      class Table
        # 表名
        # @return [String]
        attr_reader :name
        # 表の説明
        # @return [String, nil]
        attr_reader :description
        # 作者
        # @return [String, nil]
        attr_reader :author
        # 追加日
        # @return [Date, nil]
        attr_reader :added
        # 変更日
        # @return [Date, nil]
        attr_reader :modified
        # ライセンス
        # @return [String, nil]
        attr_reader :license

        # YAML を解析して Table オブジェクトに変換する
        # @param [String] yaml 表を表す YAML 文字列
        # @return [Table]
        def self.parse_yaml(yaml)
          data = YAML.load(yaml)

          name = data['Name']
          values = data['Body']
          description = data['Description']
          is_public = (data['Access'] == 'public')
          author = data['Author']
          license = data['License']

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
            description: description,
            added: added,
            modified: modified,
            public: is_public,
            author: author,
            license: license
          )
        end

        # 新しい Table インスタンスを返す
        # @param [String] name 表名
        # @param [Array<String>] values 表の値の配列
        # @param [Hash] metadata メタデータ
        # @option metadata [String] :description 表の説明
        # @option metadata [Date] :added 追加日
        # @option metadata [Date] :modified 変更日
        # @option metadata [Boolean] :public 公開されているかどうか
        # @option metadata [String] :author 作者
        # @option metadata [String] :license ライセンス
        def initialize(name, values, metadata)
          actual_metadata = {}.merge(metadata)

          @name = name
          @values = values

          @public = true & actual_metadata[:public] # 真偽値に変換する
          @description = actual_metadata[:description]
          @author = actual_metadata[:author]
          @added = actual_metadata[:added]
          @modified = actual_metadata[:modified]
          @license = actual_metadata[:license]
        end

        # 公開されているかどうかを返す
        # @return [Boolean]
        def public?
          @public
        end

        # 表から値を 1 個取り出す
        # @param [Random] random 使用する乱数生成器
        def sample(random: Random::DEFAULT)
          @values.sample(random: random)
        end
      end
    end
  end
end
