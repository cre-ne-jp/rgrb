# vim: fileencoding=utf-8

require 'parslet'

module RGRB
  module Plugin
    module Calc
      # PEG による数式の構文定義
      # @see https://ja.wikipedia.org/wiki/Parsing_Expression_Grammar
      # @see http://www.slideshare.net/takahashim/what-is-parser
      # @see http://kschiess.github.io/parslet/parser.html
      class Parser < Parslet::Parser
        root(:expr)

        # 数式
        rule(:expr) {
          term.as(:left) >> (add | sub).repeat(1).as(:lassoc_rest) |
          term
        }
        # 加算
        rule(:add) { str('+').as(:op) >> term.as(:right) }
        # 減算
        rule(:sub) { str('-').as(:op) >> term.as(:right) }

        # 項
        rule(:term) {
          exp.as(:left) >> (mul | div).repeat(1).as(:lassoc_rest) |
          exp
        }
        # 乗算
        rule(:mul) { str('*').as(:op) >> exp.as(:right) }
        # 除算
        rule(:div) { str('/').as(:op) >> exp.as(:right) }

        # 冪乗
        rule(:exp) {
          unary.as(:left) >> str('^').as(:rassoc_op) >> exp.as(:right) |
          unary
        }

        # 単項
        rule(:unary) { pos | neg | primary }
        # 単項 '+'
        rule(:pos) { str('+') >> primary }
        # 単項 '-'
        rule(:neg) { str('-').as(:unary_op) >> primary.as(:primary) }

        # 基本要素
        rule(:primary) { parened | roll | number }
        # 括弧で囲まれた数式
        rule(:parened) { str('(') >> expr >> str(')') }

        # ダイスロール
        rule(:roll) { pos_int.as(:rolls) >> match['dD'] >> pos_int.as(:sides) }
        # 数
        rule(:number) { int }
        # 整数
        rule(:int) { match['0-9'].repeat(1).as(:int) }
        # 正の整数
        rule(:pos_int) { (match['1-9'] >> match['0-9'].repeat).as(:int) }
      end
    end
  end
end
