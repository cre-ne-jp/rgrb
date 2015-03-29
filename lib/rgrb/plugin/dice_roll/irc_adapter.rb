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
        self.prefix = /\.roll[\s　]+/
        match(/([1-9]\d*)d([1-9]\d*)/i, method: :basic_dice)
        match(/d([1-9]+)/i, method: :dxx_dice)

        self.prefix = /。/
        match(/([あかさたなはまやら][あかさたなはまやらわ]*)の([あかさたなはまやら][あかさたなはまやらわ]*)/i, method: :basic_dice_ja)

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

        def basic_dice_ja(m, n_dice, max)
          message = @generator.basic_dice_ja(n_dice, max)
          m.target.send("#{m.user.nick} -> #{message}", true)
        end

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # @return [void]
        def dxx_dice(m, rolls)
          message = @generator.dxx_dice(rolls)
          m.target.send("#{m.user.nick} -> #{message}", true)
        end
      end
    end
  end
end
