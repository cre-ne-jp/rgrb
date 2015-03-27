# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/ast/unary_op_node'
require 'rgrb/plugin/calc/symbol_token'

module RGRB
  module Plugin
    module Calc
      module AST
        # 符号を反転する演算子を表すノードのクラス
        class NegNode
          include UnaryOpNode

          # 優先順位
          PRECEDENCE = 1

          def initialize(value)
            super(SymbolToken::MINUS, value)
          end

          # 評価する
          def eval
            -(@children.first.eval)
          end
        end
      end
    end
  end
end
