# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/dice_roll/generator'

describe RGRB::Plugin::DiceRoll::Generator do
  let(:generator) { described_class.new }

  describe '#dice_roll' do
    # ダイス数が多すぎるかどうか
    # [dice_roll] ダイスロールを表す文字列。'2d6' 等
    # [excess] ダイス数が多すぎる場合は true、適正な場合は false
    shared_examples 'excess_dice' do |dice_roll, excess|
      context(dice_roll) do
        let(:matches) { dice_roll.match(/(\d+)d(\d+)/).to_a }
        let(:n_dice) { matches[1].to_i }
        let(:max) { matches[2].to_i }
        let(:excess_dice_message) do
          "#{dice_roll}: ダイスが机から落ちてしまいましたの☆"
        end

        subject { generator.basic_dice(n_dice, max) }

        it do
          if excess
            should eq(excess_dice_message)
          else
            should_not eq(excess_dice_message)
          end
        end
      end
    end

    # ダイス数が多すぎる場合
    %w(1000d6 200d100).each do |dice_roll|
      include_examples 'excess_dice', dice_roll, true
    end

    # ダイス数が適正な場合
    %w(100d100 10d10 2d6).each do |dice_roll|
      include_examples 'excess_dice', dice_roll, false
    end
  end

  describe '#dice_roll (private)' do
    it '[:values] の要素がすべて「1〜ダイスの最大値」である' do
      1.upto(3) do |n_dice|
        1.upto(10) do |max|
          result = generator.send(:dice_roll, n_dice, max)
          values = result[:values]

          expect(values.all? { |x| (1..max).include?(x) }).to be(true)
        end
      end
    end

    it '[:sum] は [:values] の要素の合計と等しい' do
      1.upto(3) do |n_dice|
        1.upto(10) do |max|
          result = generator.send(:dice_roll, n_dice, max)
          values = result[:values]
          sum = result[:sum]

          expect(sum).to eq(values.reduce(0, :+))
        end
      end
    end

    # 100000d101 の出目に偏りがないことを
    # カイ二乗検定で確かめる
    #
    # 面数が 101 なのは、自由度が面数 - 1 で、カイ二乗分布表には
    # 切りの良い 100 しか載っていないから
    it '出目に偏りがない' do
      n_dice = 100_000
      max = 101
      freq = Array.new(max, 0)
      values = generator.send(:dice_roll, n_dice, max)[:values]

      values.each do |x|
        freq[x - 1] += 1
      end

      # カイ二乗値を求める
      expected_count = n_dice.to_f / max
      chi2 = freq.
        map { |count| (count - expected_count)**2 / expected_count }.
        reduce(0, :+)

      expect(chi2).to be <= 140.169 # 自由度 100、有意水準 0.5%
    end
  end

  describe '#basic_dice_message (private)' do
    shared_examples 'a message' do
      let(:condition_matches) { (/^(\d+)[Dd](\d+)$/).match(condition) }
      let(:n_dice) { condition_matches[1].to_i }
      let(:max) { condition_matches[2].to_i }
      let(:dice_roll_data) do
        {
          n_dice: n_dice,
          max: max,
          values: values,
          sum: values.reduce(0, :+)
        }
      end

      it do
        actual_message = generator.send(:basic_dice_message, dice_roll_data)
        expect(actual_message).to eq(expected_message)
      end
    end

    context '1d1 -> [1]' do
      include_examples 'a message' do
        let(:condition) { '1d1' }
        let(:values) { [1] }
        let(:expected_message) { '1d1 = [1] = 1' }
      end
    end

    context '2d6 -> [1, 6]' do
      include_examples 'a message' do
        let(:condition) { '2d6' }
        let(:values) { [1, 6] }
        let(:expected_message) { '2d6 = [1, 6] = 7' }
      end
    end

    context '3d10 -> [8, 1, 5]' do
      include_examples 'a message' do
        let(:condition) { '3d10' }
        let(:values) { [8, 1, 5] }
        let(:expected_message) { '3d10 = [8, 1, 5] = 14' }
      end
    end
  end
end
