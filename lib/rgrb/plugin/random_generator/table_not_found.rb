# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module RandomGenerator
      # 表が見つからない場合のエラーを示すクラス
      class TableNotFound < StandardError
        # 見つからなかった表名
        # @return [String]
        attr_reader :table

        # 新しい TableNotFound インスタンスを返す
        # @param [String] table 表名
        # @param [String] error_message エラーメッセージ
        def initialize(table = nil, error_message = nil)
          if !error_message && table
            error_message = "表 #{table} が見つかりません"
          end

          super(error_message)

          @table = table
        end
      end
    end
  end
end
