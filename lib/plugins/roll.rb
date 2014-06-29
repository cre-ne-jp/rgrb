# encoding: utf-8

module Roll
  Version    = 1.0
  Help    = 'http://www.cre.ne.jp/services/irc/bot'

  def basicdice(n_dice, max)
    values = Array.new(n_dice) {rand(max) + 1}
    sum = values.reduce(0, :+)

    return "dice -> #{n_dice}d#{max} = #{values} = #{sum}"
  end


end
