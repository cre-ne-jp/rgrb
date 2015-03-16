# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/dice_roll/dice_roll_result'

describe RGRB::Plugin::DiceRoll::DiceRollResult do
  shared_examples 'dice roll' do
    let(:condition_matches) { (/^(\d+)[Dd](\d+)$/).match(condition) }
    let(:rolls) { condition_matches[1].to_i }
    let(:sides) { condition_matches[2].to_i }
    let(:sum) { values.reduce(0, :+) }
    let(:dice_roll_result) { described_class.new(rolls, sides, values) }

    describe '#rolls' do
      subject { dice_roll_result.rolls }
      it { should eq(rolls) }
    end

    describe '#sides' do
      subject { dice_roll_result.sides }
      it { should eq(sides) }
    end

    describe '#values' do
      subject { dice_roll_result.values }
      it { should eq(values) }
    end

    describe '#sum' do
      subject { dice_roll_result.sum }
      it { should eq(sum) }
    end

    describe '#dice_roll_format' do
      subject { dice_roll_result.dice_roll_format }
      it { should eq(dice_roll_format) }
    end

    describe '#sw2_dll_format' do
      subject { dice_roll_result.sw2_dll_format }
      it { should eq(sw2_dll_format) }
    end

    describe '#bcdice_format' do
      subject { dice_roll_result.bcdice_format }
      it { should eq(bcdice_format) }
    end
  end

  context '1d1 -> [1]' do
    include_examples 'dice roll' do
      let(:condition) { '1d1' }
      let(:values) { [1] }
      let(:dice_roll_format) { '1d1 = [1] = 1' }
      let(:sw2_dll_format) { '[1:1]' }
      let(:bcdice_format) { '1[1]' }
    end
  end

  context '2d6 -> [2,5]' do
    include_examples 'dice roll' do
      let(:condition) { '2d6' }
      let(:values) { [2, 5] }
      let(:dice_roll_format) { '2d6 = [2,5] = 7' }
      let(:sw2_dll_format) { '[2,5:7]' }
      let(:bcdice_format) { '7[2,5]' }
    end
  end

  context '2d6 -> [6,6]' do
    include_examples 'dice roll' do
      let(:condition) { '2d6' }
      let(:values) { [6, 6] }
      let(:dice_roll_format) { '2d6 = [6,6] = 12' }
      let(:sw2_dll_format) { '[6,6:12]' }
      let(:bcdice_format) { '12[6,6]' }
    end
  end

  context '3d10 -> [9,2,6]' do
    include_examples 'dice roll' do
      let(:condition) { '3d10' }
      let(:values) { [9, 2, 6] }
      let(:dice_roll_format) { '3d10 = [9,2,6] = 17' }
      let(:sw2_dll_format) { '[9,2,6:17]' }
      let(:bcdice_format) { '17[9,2,6]' }
    end
  end

  context '3d10 -> [9,2,6]' do
    include_examples 'dice roll' do
      let(:condition) { '3d10' }
      let(:values) { [10, 10, 10] }
      let(:dice_roll_format) { '3d10 = [10,10,10] = 30' }
      let(:sw2_dll_format) { '[10,10,10:30]' }
      let(:bcdice_format) { '30[10,10,10]' }
    end
  end
end
