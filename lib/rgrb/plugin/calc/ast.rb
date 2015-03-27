# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Calc
      # 抽象構文木関連のクラスを格納するモジュール
      module AST; end
    end
  end
end

require 'rgrb/plugin/calc/token'
require 'rgrb/plugin/calc/symbol_token'

require 'rgrb/plugin/calc/ast/parenthesize'

require 'rgrb/plugin/calc/ast/node_base'
require 'rgrb/plugin/calc/ast/expr_node'

require 'rgrb/plugin/calc/ast/int_node'
require 'rgrb/plugin/calc/ast/roll_node'

require 'rgrb/plugin/calc/ast/unary_op_node'
require 'rgrb/plugin/calc/ast/neg_node'

require 'rgrb/plugin/calc/ast/binary_op_node'
require 'rgrb/plugin/calc/ast/add_node'
require 'rgrb/plugin/calc/ast/sub_node'
require 'rgrb/plugin/calc/ast/mul_node'
require 'rgrb/plugin/calc/ast/div_node'
require 'rgrb/plugin/calc/ast/exp_node'
