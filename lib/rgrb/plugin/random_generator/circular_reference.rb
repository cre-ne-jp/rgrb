# vim: fileencoding=utf-8

module RGRB
  module Plugin
    class RandomGenerator
      # 循環参照エラーを示すクラス
      class CircularReference < StandardError
        # 循環参照が起こった表名
        # @return [String]
        attr_reader :table

        def initialize(table = nil, error_message = nil)
          if !error_message && table
            error_message = "表 #{table} で循環参照が起こりました"
          end

          super(error_message)

          @table = table
        end
      end
    end
  end
end
