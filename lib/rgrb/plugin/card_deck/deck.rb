module RGRB
  module Plugin
    module CardDeck
      # カードデッキ本体を表すクラス
      #
      # YAML から変換されたハッシュの構造に依存しないように
      # 抽象化する。
      class Deck
        # デッキ名
        # @return [String]
        attr_reader :name
        # デッキの中身(札)
        # @return [Array<String>]
        attr_reader :values
        # 未使用デッキのカード枚数
        # @return [Integer]
        attr_reader :size
        # デッキの説明
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
        # 出力ヘッダ
        # @return [String, nil]
        attr_reader :header

        # YAML を解析して Deck オブジェクトに変換する
        # @param [String] yaml 表を表す YAML 文字列
        # @return [Deck]
        def self.parse_yaml(yaml)
          data = YAML.load(yaml)

          name = data['Name']
          values = data['Body']
          description = data['Description']
          author = data['Author']
          license = data['License']
          header = data['Header']

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
            author: author,
            license: license,
            header: header,
          )
        end

        # 新しい Deck インスタンスを返す
        # @param [String] name デッキ名
        # @param [Array<String>] values 表の値の配列
        # @param [Integer] size 値の数(未使用デッキのカード枚数)
        # @param [Hash] metadata メタデータ
        # @option metadata [String] :description 表の説明
        # @option metadata [Date] :added 追加日
        # @option metadata [Date] :modified 変更日
        # @option metadata [String] :author 作者
        # @option metadata [String] :license ライセンス
        # @option metadata [String] :header 出力ヘッダ
        def initialize(name, values, metadata)
          actual_metadata = {}.merge(metadata)

          @name = name
          @values = values
          @size = values.size

          @description = actual_metadata[:description]
          @author = actual_metadata[:author]
          @added = actual_metadata[:added]
          @modified = actual_metadata[:modified]
          @license = actual_metadata[:license]
          @header = actual_metadata[:header]
        end
      end
    end
  end
end
