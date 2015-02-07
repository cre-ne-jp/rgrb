# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/dice_roll/generator'

module RGRB
  module Plugin
    module DiceRoll
      # DiceRoll の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'DiceRoll')
        match(/roll[ 　]+([1-9]\d*)d([1-9]\d*)/i, method: :basic_dice)

        def initialize(*args)
          super

          @generator = Generator.new
        end

        # 基本的なダイスロールの結果を返す
        # @return [void]
        def basic_dice(m, n_dice, max)
          message = @generator.basic_dice(n_dice.to_i, max.to_i)
          m.target.send("#{m.user.nick} -> #{message}", true)
        end
      end
    end
  end
end
