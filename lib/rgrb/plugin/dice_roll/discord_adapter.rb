# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/dice_roll/constants'
require 'rgrb/plugin/dice_roll/generator'

module RGRB
  module Plugin
    module DiceRoll
      # DiceRoll の Discord アダプター
      class DiscordAdapter
        include DiscordPlugin

        set(plugin_name: 'DiceRoll')
        self.prefix = /\.roll[\s　]+/
        match(/(#{NUMS_RE})d(#{NUMS_RE})/io, method: :basic_dice)
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice)

        match(/(#{KANA_NUMS_RE})の(#{KANA_NUMS_RE})/io, method: :basic_dice_ja, :prefix => '。')
        match(/の(#{KANA_NUM_RE}+)/io, method: :dxx_dice_ja, :prefix => '。')

        def initialize(*args)
          super

          config_data = config[:plugin]
          @jadice = true
          @jadice = false if config_data['JaDice'] == false

          prepare_generator
        end

        # 基本的なダイスロールの結果を返す
        # @return [void]
        def basic_dice(m, n_dice, max)
          log_incoming(m)
          result = @generator.basic_dice(n_dice.to_i, max.to_i)
          send_channel(m.channel, "#{m.user.mention} -> #{result}")
        end

        def basic_dice_ja(m, n_dice, max)
          log_incoming(m)
          return unless @jadice

          result = @generator.basic_dice_ja(n_dice, max)
          send_channel(m.channel, "#{m.user.mention} -> #{result}")
        end

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # @return [void]
        def dxx_dice(m, rolls)
          log_incoming(m)
          result = @generator.dxx_dice(rolls)
          send_channel(m.channel, "#{m.user.mention} -> #{result}")
        end

        def dxx_dice_ja(m, rolls)
          log_incoming(m)
          return unless @jadice

          result = @generator.dxx_dice_ja(rolls)
          message = "#{m.user.mention} -> #{result}"
          send_channel(m.channel, message)
        end
      end
    end
  end
end
