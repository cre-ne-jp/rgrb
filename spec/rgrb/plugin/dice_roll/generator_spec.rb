# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/dice_roll/generator'

require 'fileutils'

describe RGRB::Plugin::DiceRoll::Generator do
  let(:generator) { described_class.new }

  let(:data_path_on_test) { File.expand_path('./data', __dir__) }

  let(:generator_set_data_path) {
    g = generator

    g.config_id = 'test'
    g.data_path = data_path_on_test
    g.configure({ 'JaDice' => true })

    g
  }

  describe '#basic_dice' do
    # ダイス数が多すぎるかどうか
    # [dice_roll] ダイスロールを表す文字列。'2d6' 等
    # [excess] ダイス数が多すぎる場合は true、適正な場合は false
    shared_examples 'excess dice' do |dice_roll, excess|
      context(dice_roll) do
        let(:matches) { dice_roll.match(/(\d+)d(\d+)/).to_a }
        let(:rolls) { matches[1].to_i }
        let(:sides) { matches[2].to_i }
        let(:excess_dice_message) do
          "#{dice_roll}: ダイスが机から落ちてしまいましたの☆"
        end

        subject { generator.basic_dice(rolls, sides) }

        it do
          if excess
            expect(subject).to eq(excess_dice_message)
          else
            expect(subject).not_to eq(excess_dice_message)
          end
        end
      end
    end

    # ダイス数が多すぎる場合
    %w(1000d6 200d100).each do |dice_roll|
      include_examples 'excess dice', dice_roll, true
    end

    # ダイス数が適正な場合
    %w(100d100 10d10 2d6).each do |dice_roll|
      include_examples 'excess dice', dice_roll, false
    end
  end

  describe '#dxx_dice' do
    # ダイス数が多すぎるかどうか
    # [dice_roll] ダイスロールを表す文字列。'd66' 等
    # [excess] ダイス数が多すぎる場合は true 、適正な場合は false
    shared_examples 'excess dxx' do |dice_roll, excess|
      context(dice_roll) do
        let(:matches) { dice_roll.match(/d([1-9]+)/).to_a }
        let(:rolls) { matches[1].to_s }
        let(:excess_dice_message) do
          "#{dice_roll}: ダイスが机から落ちてしまいましたの☆"
        end

        subject { generator.dxx_dice(rolls) }

        it do
          if excess
            expect(subject).to eq(excess_dice_message)
          else
            expect(subject).not_to eq(excess_dice_message)
          end
        end
      end
    end

    # ダイス数が多すぎる場合
    %w(d1234567891123456789212345).each do |dice_roll|
      include_examples 'excess dxx', dice_roll, true
    end

    # ダイス数が適正な場合
    %w(d66 d123456789011234567892).each do |dice_roll|
      include_examples 'excess dxx', dice_roll, false
    end
  end

  describe '#dice_roll' do
    it '#values の要素がすべて「1〜ダイスの最大値」である' do
      1.upto(3) do |rolls|
        1.upto(10) do |sides|
          result = generator.dice_roll(rolls, sides)

          expect(
            result.values.all? { |x| (1..sides).include?(x) }
          ).to be(true)
        end
      end
    end

    # 100000d100 の出目に偏りがないことを
    # カイ二乗検定で確かめる
    it '出目に偏りがない' do
      rolls = 100_000
      sides = 100
      freq = Array.new(sides, 0)
      values = generator.dice_roll(rolls, sides).values

      values.each do |x|
        freq[x - 1] += 1
      end

      # カイ二乗値を求める
      expected_count = rolls.to_f / sides
      chi2 = freq.
        map { |count| (count - expected_count)**2 / expected_count }.
        reduce(0, &:+)

      expect(chi2).to be <= 170.798 # 自由度 99、有意水準 0.001%
    end
  end

  describe '#dxx_roll' do
    it '#values の各文字がすべて「1～ダイスの最大値」である' do
      1.upto(9) do |first|
        1.upto(9) do |second|
          values = generator.dxx_roll("#{first}#{second}")

          expect( (1..first).include?(values[0]) ).to be(true)
          expect( (1..second).include?(values[1]) ).to be(true)
        end
      end
    end
  end

  describe 'データベースディレクトリの準備' do
    before do
      clean_data
    end

    after do
      clean_data
    end

    it 'ディレクトリが存在しなければ作成する' do
      expect(File.directory?("#{data_path_on_test}/test")).to be(false)

      generator_set_data_path

      expect(File.directory?("#{data_path_on_test}/test")).to be(true)
    end

    it 'ディレクトリ以外のファイルが存在したら例外を発生させる' do
      expect(File.directory?("#{data_path_on_test}/test")).to be(false)

      FileUtils.touch("#{data_path_on_test}/test")

      expect { generator_set_data_path }.to raise_error(Errno::ENOTDIR)
    end
  end

  describe 'シークレットロール' do
    let(:channel) { '#test' }

    before do
      clean_data
    end

    after do
      clean_data
    end

    it '結果を保存できる' do
      dice_roll_results = [
        'foo -> 2d6 = [5,3] = 8',
        'bar -> 2d6 = [3,2] = 5'
      ]

      dice_roll_results.each do |result|
        generator_set_data_path.save_secret_roll(channel, result)
      end

      expect(generator_set_data_path.open_dice(channel)).to eq(dice_roll_results)
    end

    describe '#open_dice' do
      it 'シークレットロール未実施時に nil を返す' do
        expect(generator_set_data_path.open_dice(channel)).to be_nil
      end
    end
  end

  # テスト用のデータディレクトリ内のファイルを削除する
  def clean_data
    FileUtils.rm_rf(Dir.glob("#{data_path_on_test}/*"))
  end
end
