# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/token'
require 'rgrb/plugin/calc/ast/expr_node'

module RGRB
  module Plugin
    module Calc
      module AST
        # 整数を表すノードのクラス
        class IntNode
          include ExprNode

          # 優先順位
          PRECEDENCE = 0

          # 値
          # @return [Integer]
          attr_reader :value

          def initialize(value_s)
            super(Token.new(:int, value_s))

            @value = value_s.to_i
          end

          def to_s
            @value.to_s
          end

          # 中置記法に変換する
          # @return [String]
          def to_infix_notation
            to_s
          end

          # 評価する
          # @return [Integer]
          def eval
            @value
          end
        end
      end
    end
  end
end
