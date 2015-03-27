# vim: fileencoding=utf-8

require 'rgrb/plugin/calc/token'
require 'rgrb/plugin/calc/ast/expr_node'

module RGRB
  module Plugin
    module Calc
      module AST
        # ダイスロールを表すノードのクラス
        class RollNode
          include ExprNode

          # 優先順位
          PRECEDENCE = 0

          # ダイスを振る回数
          # @return [Integer]
          attr_reader :rolls
          # ダイスの面数
          # @return [Integer]
          attr_reader :sides
          # 出目
          # @return [Array<Integer>]
          attr_reader :values
          # 出目の合計
          # @return [Integer]
          attr_reader :sum

          def initialize(rolls, sides)
            @rolls = rolls.eval
            @sides = sides.eval
            @values = Array.new(@rolls) { rand(1...@sides) }
            @sum = values.reduce(0, &:+)

            super(Token.new(:roll, dice_notation))
          end

          def to_s
            "#{@sum} <#{dice_notation} -> [#{@values.join(',')}]>"
          end

          # 中置記法に変換する
          def to_infix_notation
            to_s
          end

          # 評価する
          # @return [Integer]
          def eval
            @sum
          end

          # ダイス表記を返す
          # @return [String]
          def dice_notation
            "#{@rolls}d#{@sides}"
          end
        end
      end
    end
  end
end
