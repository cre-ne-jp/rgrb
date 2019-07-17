# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/dice_roll/constants'
require 'rgrb/plugin/dice_roll/generator'
require 'rgrb/plugin/util/notice_multi_lines'

module RGRB
  module Plugin
    module DiceRoll
      # DiceRoll の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter
        include Util::NoticeMultiLines

        set(plugin_name: 'DiceRoll')
        self.prefix = /\.roll[\s　]+/
        match(/(#{NUMS_RE})d(#{NUMS_RE})/io, method: :basic_dice)
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice)
        match(/(#{NUMS_RE})d(#{NUMS_RE})/io, method: :basic_dice_secret, prefix: /\.sroll[\s　]+/)
        match('-open', method: :open_dice, prefix: '.sroll')
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice_secret, prefix: /\.sroll[\s　]+/)

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
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end

        # 基本的なダイスロールの結果を返す
        # シークレットロール
        # @return [void]
        def basic_dice_secret(m, n_dice, max)
          @generator.config_id = config[:config_id]
          log_incoming(m)
          result = @generator.basic_dice(n_dice.to_i, max.to_i)
          result = "#{m.user.nick} -> #{result}"
          @generator.save_secret_roll(m.target.name, result)

          message = ''
          case(m.target.class.to_s)
          when('Cinch::Channel')
            message = "チャンネル #{m.target.name} でのシークレットロール: #{result}"
            m.user.send(message, true)
            log_notice(m.user, message)

            message = "#{m.user.nick}: シークレットロールを保存しました"
          when('Cinch::User')
            message = 'シークレットロールを保存しました'
          end

          m.target.send(message, true)
          log_notice(m.target, message)
        end

        def open_dice(m)
          result = @generator.open_dice(m.target.name)
          messages = if result.empty? 
            ["#{m.target.name} にはシークレットロールがありません"]
          else
            [
              "#{m.target.name} のシークレットロール: #{result.size} 件",
              result,
              "シークレットロールここまで"
            ].flatten
          end
pp messages
          notice_multi_lines(messages, m.target)
        end

        # 日本語版の basic_dice
        # @return [void]
        def basic_dice_ja(m, n_dice, max)
          log_incoming(m)
          return unless @jadice

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

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # シークレットロール
        # @return [void]
        def dxx_dice_secret(m, rolls)
          log_incoming(m)
          result = @generator.dxx_dice(rolls)
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end

        # 日本語版の dxx_dice
        # @return [void]
        def dxx_dice_ja(m, rolls)
          log_incoming(m)
          return unless @jadice

          result = @generator.dxx_dice_ja(rolls)
          message = "#{m.user.nick} -> #{result}"
          m.target.send(message, true)
          log_notice(m.target, message)
        end
      end
    end
  end
end
