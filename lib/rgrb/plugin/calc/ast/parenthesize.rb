# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Calc
      module AST
        # 中置記法における括弧で囲む処理
        module Parenthesize
          # node を中置記法に変換し、適切に括弧で囲む
          # @param [ExprNode]
          def parenthesize(node, right = false)
            # 括弧で囲んだ文字列を返す
            # @return [String]
            def parenthesized(s)
              "(#{s})"
            end

            infix_notation = node.to_infix_notation

            case node
            when RollNode, UnaryOpNode
              parenthesized(infix_notation)
            when BinaryOpNode
              parenthesize_by_precedence = lambda do |ineq_sign|
                # ineq_sign: 不等号
                if self.class::PRECEDENCE.send(ineq_sign, node.class::PRECEDENCE)
                  parenthesized(infix_notation)
                else
                  infix_notation
                end
              end

              ineq_sign =
                case
                when node.kind_of?(ExpNode)            then :<=
                when right && !self.class::COMMUTATIVE then :<=
                else :<
                end

              parenthesize_by_precedence[ineq_sign]
            else
              infix_notation
            end
          end
          private :parenthesize
        end
      end
    end
  end
end
