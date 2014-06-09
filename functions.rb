

def basicdice(n_dice, max)
	values = Array.new(n_dice) {rand(max) + 1}
	sum = values.reduce(0, :+)

	return "dice -> #{n_dice}d#{max} = #{values} = #{sum}
end

