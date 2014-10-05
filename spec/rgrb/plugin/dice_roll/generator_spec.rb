# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/dice_roll/generator'

class RGRB::Plugin::DiceRoll::Generator
  public :dice_roll
  public :basic_dice_message
end

describe RGRB::Plugin::DiceRoll::Generator do
  let(:generator) { described_class.new }

  describe '#dice_roll (private)' do
    it '[:values] の要素がすべて「1〜ダイスの最大値」である' do
      1.upto(3) do |n_dice|
        1.upto(10) do |max|
          result = generator.dice_roll(n_dice, max)
          values = result[:values]

          expect(values.all? { |x| (1..max).include?(x) }).to be(true)
        end
      end
    end

    it '[:sum] は [:values] の要素の合計と等しい' do
      1.upto(3) do |n_dice|
        1.upto(10) do |max|
          result = generator.dice_roll(n_dice, max)
          values = result[:values]
          sum = result[:sum]

          expect(sum).to eq(values.reduce(0, :+))
        end
      end
    end
  end

  describe '#basic_dice_message (private)' do
    shared_examples 'a message' do
      let(:condition_matches) { (/^(\d+)[Dd](\d+)$/).match(condition) }
      let(:n_dice) { condition_matches[1].to_i }
      let(:max) { condition_matches[2].to_i }
      let(:result) do
        { values: values, sum: values.reduce(0, :+) }
      end

      it do
        actual_message = generator.basic_dice_message(n_dice, max, result)
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
