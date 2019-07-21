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
        match(/d(#{NUM_RE}+)/io, method: :dxx_dice_secret, prefix: /\.sroll[\s　]+/)
        match('-open', method: :open_dice, prefix: '.sroll')

        match(/(#{KANA_NUMS_RE})の(#{KANA_NUMS_RE})/io, method: :basic_dice_ja, :prefix => '。')
        match(/の(#{KANA_NUM_RE}+)/io, method: :dxx_dice_ja, :prefix => '。')

        def initialize(*args)
          super

          config_data = config[:plugin]
          @jadice = config_data['JaDice'] == false ? false : true

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
        # @param [Cinch::Message] m
        # @return [void]
        def open_dice(m)
          result = @generator.open_dice(m.target.name)
          messages = if result.nil?
              ["#{m.target.name} にはシークレットロール結果がありません"]
            else
              [
                "#{m.target.name} のシークレットロール: #{result.size} 件",
                result,
                "シークレットロールここまで"
              ].flatten
            end
          notice_multi_lines(messages, m.target)
        end

        private

        # ダイスロール結果を整形して IRC に送信する
        # @param [Cinch::Message] m
        # @param [String] result ダイスロール結果
        # @param [Boolean] secret シークレットダイスか？
        # @option secret true  シークレットダイス
        # @option secret false オープンダイス
        # @return [void]
        def send_result(m, result, secret = false)
          result = "#{m.user.nick} -> #{result}"

          message = if secret
            @generator.save_secret_roll(m.target.name, result)

            case(m.target)
            when(Cinch::Channel)
              message = "チャンネル #{m.target.name} でのシークレットロール: #{result}"
              m.user.send(message, true)
              log_notice(m.user, message)

              "#{m.user.nick}: シークレットロールを保存しました"
            when(Cinch::User)
              'シークレットロールを保存しました'
            end
          else
            result
          end

          m.target.send(message, true)
          log_notice(m.target, message)
        end
      end
    end
  end
end
