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

            case
            when value.nil?
              nil
            when value.kind_of?(Date)
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
            is_public: is_public,
            author: author,
            license: license
          )
        end

        # 新しい Table インスタンスを返す
        # @param [String] name 表名
        # @param [Array<String>] values 表の値の配列
        # @param [String, nil] description 表の説明
        # @param [Date, nil] added 追加日
        # @param [Date, nil] modified 変更日
        # @param [Boolean] is_public 公開されているかどうか
        # @param [String, nil] author 作者
        # @param [String, nil] license ライセンス
        def initialize(
          name,
          values,
          description: nil,
          added: nil,
          modified: nil,
          is_public: true,
          author: nil,
          license: nil
        )
          @name = name
          @values = values

          @public = !!is_public
          @description = description
          @author = author
          @added = added
          @modified = modified
          @license = license
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
