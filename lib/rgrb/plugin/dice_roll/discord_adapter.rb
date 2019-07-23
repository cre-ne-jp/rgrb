# vim: fileencoding=utf-8

require 'rgrb/plugin_base/discord_adapter'
require 'rgrb/plugin/dice_roll/constants'
require 'rgrb/plugin/dice_roll/generator'

module RGRB
  module Plugin
    module DiceRoll
      # DiceRoll の Discord アダプター
      class DiscordAdapter
        include PluginBase::DiscordAdapter

        set(plugin_name: 'DiceRoll')
        self.prefix = /\.roll[\s　]+/
        match(/(#{NUMS_RE})d(#{NUMS_RE})/io, method: :basic_dice)
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice)
        match(/(#{NUMS_RE})d(#{NUMS_RE})/io, method: :basic_dice_secret, prefix: /\.sroll[\s　]+/)
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice_secret, prefix: /\.sroll[\s　]+/)
        match('-open', method: :open_dice, prefix: '.sroll')

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
          send_result(m, @generator.basic_dice(n_dice.to_i, max.to_i))
        end

        # 基本的なダイスロールの結果を返す
        # シークレットロール
        # @return [void]
        def basic_dice_secret(m, n_dice, max)
          log_incoming(m)
          send_result(m, @generator.basic_dice(n_dice.to_i, max.to_i), true)
        end

        # 日本語版の basic_dice
        # @return [void]
        def basic_dice_ja(m, n_dice, max)
          log_incoming(m)
          return unless @jadice

          send_result(m, @generator.basic_dice_ja(n_dice, max))
        end

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # @return [void]
        def dxx_dice(m, rolls)
          log_incoming(m)
          send_result(m, @generator.dxx_dice(rolls))
        end

        # d66 など、出目をそのままつなげるダイスロールの結果を返す
        # シークレットロール
        # @return [void]
        def dxx_dice_secret(m, rolls)
          log_incoming(m)
          send_result(m, @generator.dxx_dice(rolls), true)
        end

        # 日本語版の dxx_dice
        # @return [void]
        def dxx_dice_ja(m, rolls)
          log_incoming(m)
          return unless @jadice

          send_result(m, @generator.dxx_dice_ja(rolls))
        end

        # シークレットロールを表示する
        # @return [void]
        def open_dice(m)
          result = @generator.open_dice(m.channel.id.to_s)
          messages = if result.nil?
              "##{m.channel.name} にはシークレットロール結果がありません"
            else
              [
                "##{m.channel.name} のシークレットロール: #{result.size} 件",
                result,
                "シークレットロールここまで"
              ].flatten
            end
          send_channel(m.channel, messages)
        end

        private

        # シークレットロール結果を保存し、Discord に報告する
        # @param [] m
        # @param [String] result ダイスロール結果
        # @param [Boolean] secret シークレットダイスか？
        # @option secret true  シークレットダイス
        # @option secret false オープンダイス
        # @return [void]
        def send_result(m, result, secret = false)
          message = if secret
              @generator.save_secret_roll(
                m.channel.id.to_s,
                "#{m.user.name} -> #{result}"
              )
              "#{m.user.mention}: シークレットロールを保存しました"
            else
              "#{m.user.mention} -> #{result}"
            end

          send_channel(m.channel, message)
        end
      end
    end
  end
end
