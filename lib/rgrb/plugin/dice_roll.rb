# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module Plugin
    # ダイスロールを行うプラグイン
    #
    # メルセンヌ・ツイスタを用いて均一な乱数を生成します。
    class DiceRoll
      include Cinch::Plugin

      match /^([1-9]\d*)d([1-9]\d*)/i, method: :basic_dice, use_prefix: false

      # NOTICE で基本的なダイスロールの結果を返す
      def basic_dice(m, n_dice, max)
        result = dice_roll(n_dice.to_i, max.to_i)
        m.channel.notice(
          "#{m.user.nick} -> #{n_dice}d#{max} = #{result[:values]} = #{result[:sum]}"
        )
      end

      private

      # ダイスロールの結果を返す
      # @param [Fixnum] n ダイスの個数
      # @param [Fixnum] max ダイスの最大値
      # @return [Fixnum]
      def dice_roll(n_dice, max)
        values = Array.new(n_dice) {rand(max) + 1}
        sum = values.reduce(0, :+)

        {values: values, sum: sum}
      end
    end
  end
end
