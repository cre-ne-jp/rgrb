# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/detatoko/generator'

module RGRB
  module Plugin
    module Detatoko
      # Detatoko の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'Detatoko')
        self.prefix = '.d'
        match(/s(\d{,2})([^\+][ 　]|$)/i, method: :skill_decision)
        match(/s(\d{,2})\+(\d{,2})/i, method: :skill_decision)
        match(/(v|m)st/i, method: :stigma)

        def initialize(*args)
          super

          @generator = Generator.new
          header = "でたとこサーガ "
        end

        # スキルランクから判定値を得る
        # @return [void]
        def skill_decision(m, skill_rank, solid = 0)
          header = "#{header}[#{m.user.nick}]<判定値>: "
          message = @generator.skill_decision(skill_rank.to_i, solid.to_i)
          m.target.send(header + message, true)
        end

        # 烙印(p.63)を得る
        # @return [void]
        def stigma(m, type)
          tname = case type
          when 'v'
            '体'
          when 'm'
            '気'
          end
          header = "#{header}[#{m.user.nick}]<#{tname}力烙印>: "
          message = @generator.stigma(type)
          m.target.send(header + message, true)
        end
      end
    end
  end
end
