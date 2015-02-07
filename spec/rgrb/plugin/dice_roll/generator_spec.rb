# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/dice_roll/generator'

describe RGRB::Plugin::DiceRoll::Generator do
  let(:generator) { described_class.new }

  describe '#dice_roll' do
    let(:excess_dice_message) { 'ダイスが机から落ちてしまいましたの☆' }

    context '1000d6' do
      subject { generator.basic_dice(1000, 6) }
      it { should eq(excess_dice_message) }
    end

    context '200d100' do
      subject { generator.basic_dice(1000, 100) }
      it { should eq(excess_dice_message) }
    end

    context '100d100' do
      subject { generator.basic_dice(100, 100) }
      it { should_not eq(excess_dice_message) }
    end

    context '10d10' do
      subject { generator.basic_dice(10, 10) }
      it { should_not eq(excess_dice_message) }
    end

    context '2d6' do
      subject { generator.basic_dice(2, 6) }
      it { should_not eq(excess_dice_message) }
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
