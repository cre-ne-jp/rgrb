# vim: fileencoding=utf-8

require 'parslet'
require 'rgrb/plugin/calc/ast'
require 'rgrb/plugin/calc/invalid_operator_error'

module RGRB
  module Plugin
    module Calc
      # 構文木から抽象構文木への変形を表すクラス
      # @see http://kschiess.github.io/parslet/transform.html
      class Transform < Parslet::Transform
        # 二項演算子の文字に対応するノードのクラス
        BINARY_OP_NODE_CLASS = {
          '+' => AST::AddNode,
          '-' => AST::SubNode,
          '*' => AST::MulNode,
          '/' => AST::DivNode,
          '^' => AST::ExpNode
        }

        # 単項演算子の文字に対応するノードのクラス
        UNARY_OP_NODE_CLASS = {
          '-' => AST::NegNode
        }

        # 左結合の二項演算子を表すノードへの変形
        rule(left: simple(:left), lassoc_rest: subtree(:rest)) {
          current_left = left
          current_node = nil

          # 最も右にある演算子を根とする木を作る
          # 左にある演算子を根とする木を、ひとつ右の演算子を根とする木の
          # 左側の子要素にしていく
          until rest.empty?
            sub = rest.shift
            op = sub[:op].to_s
            right = sub[:right]

            unless BINARY_OP_NODE_CLASS.key?(op)
              raise InvalidOperatorError, op
            end

            node_class = BINARY_OP_NODE_CLASS[op]
            current_node = node_class.new(current_left, right)
            current_left = current_node
          end

          # 最も右にある演算子を根とする木を返す
          current_node
        }

        # 右結合の二項演算子を表すノードへの変形
        rule(
          left: simple(:left), rassoc_op: simple(:op), right: simple(:right)
        ) {
          op_s = op.to_s

          unless BINARY_OP_NODE_CLASS.key?(op_s)
            raise InvalidOperatorError, op_s
          end

          node_class = BINARY_OP_NODE_CLASS[op_s]
          node_class.new(left, right)
        }

        # 単項演算子を表すノードへの変形
        rule(unary_op: simple(:op), primary: simple(:value)) {
          op_s = op.to_s

          unless UNARY_OP_NODE_CLASS.key?(op_s)
            raise InvalidOperatorError, op_s
          end

          node_class = UNARY_OP_NODE_CLASS[op_s]
          node_class.new(value)
        }

        # 整数を表すノードへの変形
        rule(int: simple(:value)) { AST::IntNode.new(value) }

        # ダイスロールを表すノードへの変形
        rule(rolls: simple(:rolls), sides: simple(:sides)) {
          AST::RollNode.new(rolls, sides)
        }
      end
    end
  end
end
