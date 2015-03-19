# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module RandomGenerator
      # 非公開の表を参照した場合のエラーを示すクラス
      class PrivateTable < StandardError
        # 非公開の表名
        # @return [String]
        attr_reader :table

        # 新しい PrivateTable インスタンスを返す
        # @param [String] table 表名
        # @param [String] error_message エラーメッセージ
        def initialize(table = nil, error_message = nil)
          if !error_message && table
            error_message = "表 #{table} は非公開です"
          end

          super(error_message)

          @table = table
        end
      end
    end
  end
end
