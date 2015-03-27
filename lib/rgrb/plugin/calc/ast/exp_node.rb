# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/ast/binary_op_node'
require 'rgrb/plugin/calc/symbol_token'

module RGRB
  module Plugin
    module Calc
      module AST
        # 冪乗演算子を表すノードのクラス
        class ExpNode
          include BinaryOpNode

          # 可換性
          COMMUTATIVE = false
          # 優先順位
          PRECEDENCE = 20
          # 中置記法で空白を挿入するかどうか
          INFIX_SPACING = false

          def initialize(left, right)
            super(left, SymbolToken::HAT, right)
          end

          # 評価する
          def eval
            (@children[0].eval) ** (@children[1].eval)
          end
        end
      end
    end
  end
end
