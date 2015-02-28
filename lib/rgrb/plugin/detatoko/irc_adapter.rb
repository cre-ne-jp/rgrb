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
        match(/s(\d{,2})$/i, method: :skill_decision)
        match(/s(\d{,2})\+(\d{,2})/i, method: :skill_decision)

        def initialize(*args)
          super

          @generator = Generator.new
        end

        # でたとこ用ダイスロールを返す
        # @return [void]
        def skill_decision(m, skill_level, solid = 0)
          message = @generator.skill_decision(skill_level.to_i, solid.to_i)
          m.target.send("#{m.user.nick} -> #{message}", true)
        end
      end
    end
  end
end
