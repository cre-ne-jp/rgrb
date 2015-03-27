# vim: fileencoding=utf-8

require 'parslet'

require 'rgrb/plugin/calc/parser'
require 'rgrb/plugin/calc/transform'

module RGRB
  module Plugin
    # 計算機プラグイン
    module Calc
      # Calc の 出力テキスト生成器
      class Generator
        # 数式を解釈して計算を行い、結果を文字列で返す
        # @param [String] expression 数式
        # @return [String]
        def calc(expression)
          parser = Parser.new
          transform = Transform.new

          begin
            syntax_tree = parser.parse(expression)
            ast = transform.apply(syntax_tree)

            "#{ast.to_infix_notation} = #{ast.eval}"
          rescue Parslet::ParseFailed => parse_failure
           "#{expression}: 構文エラー (#{parse_failure})"
          rescue ZeroDivisionError
            "#{ast.to_infix_notation}: 0 で割ることはできませんわっ"
          rescue => e
            "#{expression}: エラー (#{e})"
          end
        end
      end
    end
  end
end
