# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Calc
      # 記号字句
      module SymbolToken
        PLUS = Token.new(:PLUS, '+'.freeze)
        MINUS = Token.new(:MINUS, '-'.freeze)
        ASTERISK = Token.new(:ASTERISK, '*'.freeze)
        SLASH = Token.new(:SLASH, '/'.freeze)
        HAT = Token.new(:HAT, '^'.freeze)
      end
    end
  end
end
