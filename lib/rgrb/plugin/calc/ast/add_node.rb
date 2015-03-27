# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/ast/binary_op_node'
require 'rgrb/plugin/calc/symbol_token'

module RGRB
  module Plugin
    module Calc
      module AST
        # 加算演算子を表すノードのクラス
        class AddNode
          include BinaryOpNode

          # 可換性
          COMMUTATIVE = true
          # 優先順位
          PRECEDENCE = 40
          # 中置記法で空白を挿入するかどうか
          INFIX_SPACING = true

          def initialize(left, right)
            super(left, SymbolToken::PLUS, right)
          end
        end
      end
    end
  end
end
