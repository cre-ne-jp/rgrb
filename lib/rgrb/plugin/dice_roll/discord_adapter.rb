# vim: fileencoding=utf-8

require 'rgrb/discord_plugin'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/dice_roll/constants'
require 'rgrb/plugin/dice_roll/generator'

module RGRB
  module Plugin
    module DiceRoll
      # DiceRoll の Discord アダプター
      class DiscordAdapter
        include RGRB::DiscordPlugin
        include ConfigurableAdapter

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
          result = @generator.basic_dice(n_dice.to_i, max.to_i)
          message = "#{m.user.nick} -> #{result}"
          m.send_message(message)
        end

        def basic_dice_ja(m, n_dice, max)
          return unless @jadice

          result = @generator.basic_dice_ja(n_dice, max)
          message = "#{m.user.nick} -> #{result}"
          m.send_message(message)
        end

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # @return [void]
        def dxx_dice(m, rolls)
          result = @generator.dxx_dice(rolls)
          message = "#{m.user.nick} -> #{result}"
          m.send_message(message)
        end

        def dxx_dice_ja(m, rolls)
          return unless @jadice

          result = @generator.dxx_dice_ja(rolls)
          message = "#{m.user.nick} -> #{result}"
          m.send_message(message)
        end
      end
    end
  end
end
