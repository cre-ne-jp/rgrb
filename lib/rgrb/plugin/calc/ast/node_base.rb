# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Calc
      module AST
        # 抽象構文木のノードの共通部分
        module NodeBase
          # 字句
          # @return [Token]
          attr_reader :token
          # 子要素
          # @return [NodeBase]
          attr_reader :children

          def initialize(token = nil)
            @token = token
            @children = []
          end

          # 字句のない nil ノードかどうかを返す
          # @return [Boolean]
          def nil_node?
            @token.nil?
          end

          # 子要素を追加する
          # @param [NodeBase] node 子要素
          # @return [self]
          def add_child(node)
            @children << node
            self
          end

          def to_s
            nil_node? ? 'nil' : @token.to_s
          end

          # 木構造を表す S 式に変換する
          # @return [String]
          def to_tree_s
            if @children.empty?
              to_s
            else
              "(#{self} #{@children.map(&:to_tree_s).join(' ')})"
            end
          end
        end
      end
    end
  end
end
