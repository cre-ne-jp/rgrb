# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Calc
      # 無効な演算子を検出した場合のエラーを表すクラス
      class InvalidOperatorError < StandardError
        # エラーメッセージ
        # @return [String]
        attr_reader :message

        def initialize(operator)
          @operator = operator
          @message = "invalid operator: #{@operator}"
        end

        alias to_s message
      end
    end
  end
end
