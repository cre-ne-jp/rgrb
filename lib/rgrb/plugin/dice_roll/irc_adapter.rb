# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/dice_roll/constants'
require 'rgrb/plugin/dice_roll/generator'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module DiceRoll
      # DiceRoll の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::Logging

        set(plugin_name: 'DiceRoll')
        self.prefix = /\.roll[\s　]+/
        match(/(#{NUMS_RE})d(#{NUMS_RE})/io, method: :basic_dice)
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice)

        match(/(#{KANA_NUMS_RE})の(#{KANA_NUMS_RE})/io, method: :basic_dice_ja, :prefix => '。')
        match(/の(#{KANA_NUM_RE}+)/io, method: :dxx_dice_ja, :prefix => '。')

        def initialize(*args)
          super

          @generator = Generator.new
        end

        # 基本的なダイスロールの結果を返す
        # @return [void]
        def basic_dice(m, n_dice, max)
          log_incoming(m)
          result = @generator.basic_dice(n_dice.to_i, max.to_i)
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end

        def basic_dice_ja(m, n_dice, max)
          log_incoming(m)
          result = @generator.basic_dice_ja(n_dice, max)
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # @return [void]
        def dxx_dice(m, rolls)
          log_incoming(m)
          result = @generator.dxx_dice(rolls)
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end

        def dxx_dice_ja(m, rolls)
          log_incoming(m)
          result = @generator.dxx_dice_ja(rolls)
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end
      end
    end
  end
end
