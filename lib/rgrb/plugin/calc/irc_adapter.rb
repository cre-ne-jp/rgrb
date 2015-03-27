# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/calc/generator'

module RGRB
  module Plugin
    module Calc
      # Calc の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'Calc')
        match(
          %r!calc[\s　]+([\d+\-*/^()d]+)!, method: :calc, use_prefix: false
        )

        def initialize(*)
          super

          @generator = Generator.new
        end

        # 数式を解釈して計算を行う
        # @return [void]
        def calc(m, expression)
          result = @generator.calc(expression)
          m.target.send("#{m.user.nick} -> #{result}", true)
        end
      end
    end
  end
end
