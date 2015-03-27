# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/ast/node_base'
require 'rgrb/plugin/calc/ast/parenthesize'

module RGRB
  module Plugin
    module Calc
      module AST
        # 二項演算子を表すノードのクラス
        module BinaryOpNode
          include NodeBase
          include Parenthesize

          def initialize(left, op_token, right)
            super(op_token)

            add_child(left)
            add_child(right)
          end

          # 評価する
          def eval
            @children[0].eval.send(@token.text, @children[1].eval)
          end

          # 中置記法に変換する
          # @return [String]
          def to_infix_notation
            elements = [
              parenthesize(@children[0]),
              @token,
              parenthesize(@children[1], true)
            ]
            sep = self.class::INFIX_SPACING ? ' '.freeze : ''.freeze
            elements.join(sep)
          end
        end
      end
    end
  end
end
