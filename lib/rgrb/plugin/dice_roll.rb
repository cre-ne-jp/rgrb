# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module Plugin
    # ダイスロールを行うプラグイン
    #
    # メルセンヌ・ツイスタを用いて均一な乱数を生成します。
    class DiceRoll
      include Cinch::Plugin

      private
      # ダイスロールの結果を返す
      # @param [Fixnum] n ダイスの個数
      # @param [Fixnum] max ダイスの最大値
      # @return [Fixnum]
      def dice_roll(n, max)
      end
    end
  end
end

module Roll
  Version    = 1.0
  Help    = 'http://www.cre.ne.jp/services/irc/bot'

  def basicdice(n_dice, max)
    values = Array.new(n_dice) {rand(max) + 1}
    sum = values.reduce(0, :+)

    return "dice -> #{n_dice}d#{max} = #{values} = #{sum}"
  end


end
