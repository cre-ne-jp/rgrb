# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/ast/node_base'
require 'rgrb/plugin/calc/ast/parenthesize'

module RGRB
  module Plugin
    module Calc
      module AST
        # 単項演算子の共通部分
        module UnaryOpNode
          include NodeBase
          include Parenthesize

          def initialize(op_token, value)
            super(op_token)

            add_child(value)
          end

          # 中置記法に変換する
          # @return [String]
          def to_infix_notation
            "#{@token}#{parenthesize(@children.first)}"
          end
        end
      end
    end
  end
end
