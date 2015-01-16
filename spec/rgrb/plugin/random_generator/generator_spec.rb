# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/random_generator/generator'

describe RGRB::Plugin::RandomGenerator::Generator do
  let(:generator) do
    obj = described_class.new
    obj.send(:load_data, "#{__dir__}/data/*.yaml")

    obj
  end

  describe '#get_value_from (private)' do
    shared_examples 'one line' do
      subject { generator.send(:get_value_from, table) }
      it { should eq(expected_text) }
    end

    context 'hiragana' do
      include_examples 'one line' do
        let(:table) { 'hiragana' }
        let(:expected_text) { 'あ' }
      end
    end

    context 'hiragana2' do
      include_examples 'one line' do
        let(:table) { 'hiragana2' }
        let(:expected_text) { '%%hiragana%%%%hiragana%%' }
      end
    end

    context 'HA06event' do
      include_examples 'one line' do
        let(:table) { 'HA06event' }
        let(:expected_text) { '%%HA06pretty%%が%%HA06action%%' }
      end
    end

    context '存在しない表の名前が指定される場合' do
      it do
        expect { generator.send(:get_value_from, 'none') }.
          to raise_error(RGRB::Plugin::RandomGenerator::TableNotFound)
      end
    end

    context 'hiraganarand' do
      # 各値が偏りなく出ることのテスト
      #
      # 要素数 10 の表から 1000 回取得したときの各値の出現回数を調べる
      # 二項分布 B(1000, 0.1) を正規分布で近似して
      # 正常な出現回数の範囲を算出
      #
      # 二項分布、正規分布については Wikipedia を参照
      #
      # μ = np = 1000 * 0.1 = 100
      # σ = (np(1 - p))^(1/2) = (1000 * 0.1 * 0.9)^(1/2) ≒ 9.5
      # 3σ ≒ 28.5
      # μ - 3σ ≦ 出現回数 ≦ μ + 3σ となる確率は約 99.73%
      # 71 ≦ 出現回数 ≦ 129 となる確率は 99.73% より大きい
      #
      # よって、テスト 1000 回につき成功回数の期待値は 997 より大きい
      it '各値が偏りなく出る' do
        table = 'hiraganarand'
        data = generator.
          instance_variable_get(:@table)['hiraganarand'].
          instance_variable_get(:@values)
        freq = Hash[
          data.map { |s| [s, 0] }
        ]

        1000.times do
          freq[generator.send(:get_value_from, table)] += 1
        end

        expect(freq.each_value.all? { |n| (71..129).include?(n) }).
          to be(true)
      end
    end
  end

  describe '#replace_var_with_value (private)' do
    shared_examples 'correctly replaced' do |root_table, result|
      it %Q("#{result}" に置換される) do
        data = generator.
          instance_variable_get(:@table)[root_table].
          instance_variable_get(:@values)
        from = data.first
        expect(generator.send(:replace_var_with_value, from, root_table)).
          to eq(result)
      end
    end

    shared_examples 'raise error' do |root_table, error_class|
      it do
        from = generator.send(:get_value_from, root_table)
        expect { generator.send(:replace_var_with_value, from, root_table) }.
          to raise_error(error_class)
      end
    end

    context 'hiragana2' do
      include_examples 'correctly replaced', 'hiragana2', 'ああ'
    end

    context 'HA06event' do
      include_examples(
        'correctly replaced',
        'HA06event',
        'ちいさな猫が楽しそうにしていた'
      )
    end

    context 'hiraganarand2' do
      it '100 回取り出したとき、値がすべて同じではない' do
        table = 'hiraganarand2'
        from = generator.send(:get_value_from, table)
        results = Array.new(100) do
          generator.send(:replace_var_with_value, from, table)
        end

        expect(results.uniq.length).to be > 1
      end
    end

    context '存在しない表の名前が含まれている場合' do
      include_examples(
        'raise error',
        'notfound',
        RGRB::Plugin::RandomGenerator::TableNotFound
      )
    end

    context '循環参照' do
      include_examples(
        'raise error',
        'self',
        RGRB::Plugin::RandomGenerator::CircularReference
      )
    end
  end
end
