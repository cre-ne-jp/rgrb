# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # ダイスロールを行うプラグイン
    #
    # メルセンヌ・ツイスタを用いて均一な乱数を生成します。
    module DiceRoll
      # DiceRoll の出力テキスト生成器
      class Generator
        def initialize
          @random = Random.new
        end

        # 基本的なダイスロールの結果を返す
        # @param [Fixnum] n_dice ダイスの個数
        # @param [Fixnum] max ダイスの最大値
        # @return [String]
        def basic_dice(n_dice, max)
          basic_dice_message(n_dice, max, dice_roll(n_dice, max))
        end

        # ダイスロールの結果を返す
        # @param [Fixnum] n_dice ダイスの個数
        # @param [Fixnum] max ダイスの最大値
        # @return [Hash]
        def dice_roll(n_dice, max)
          values = Array.new(n_dice) { @random.rand(1..max) }
          sum = values.reduce(0, :+)

          { values: values, sum: sum }
        end
        private :dice_roll

        # 基本的なダイスロールのメッセージを返す
        # @param [Fixnum] n_dice ダイスの個数
        # @param [Fixnum] max ダイスの最大値
        # @param [Hash] result ダイスロールの結果のハッシュ
        # @return [String]
        def basic_dice_message(n_dice, max, result)
          "#{n_dice}d#{max} = #{result[:values]} = #{result[:sum]}"
        end
        private :basic_dice_message
      end
    end
  end
end
