# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Calc
      # 字句を表すクラス
      class Token
        # 字句の種類
        # @return [Symbol]
        attr_reader :type
        # 字句の文字列
        # @return [String]
        attr_reader :text

        def initialize(type, text)
          @type = type
          @text = text
        end

        def to_s
          @text
        end
      end
    end
  end
end
