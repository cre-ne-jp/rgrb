# vim: fileencoding=utf-8

require_relative '../../spec_helper'
require 'rgrb/plugin/random_generator'

class RGRB::Plugin::RandomGenerator
  # テストが動くように、初期化処理で何もしないようにする
  def initialize; end

  public :get_value_from
  public :replace_var_with_value
end

describe RGRB::Plugin::RandomGenerator do
  let!(:rg_data) do
    {
      'hiragana' => ['あ'],
      'hiragana2' => ['%%hiragana%%%%hiragana%%'],
      'hiraganarand' => %w(あ い う え お か き く け こ),

      'HA06event' => ['%%HA06pretty%%が%%HA06action%%'],
      'HA06pretty' => ['ちいさな%%animal%%'],
      'HA06action' => ['楽しそうにしていた'],
      'animal' => ['猫'],

      'self' => ['%%self%%'],
      'notfound' => ['%%none%%']
    }
  end

  let(:rg) do
    obj = described_class.new
    rg_data_v = rg_data

    obj.instance_eval do
      @table = rg_data_v
    end

    obj
  end

  describe 'TABLE_RE' do
    let(:table_re) { described_class::TABLE_RE }

    context '"HA06event"' do
      subject { 'HA06event' }
      it { should match(table_re) }
    end

    context '"janken_choki"' do
      subject { 'janken_choki' }
      it { should match(table_re) }
    end

    context '"n01-2"' do
      subject { 'n01-2' }
      it { should match(table_re) }
    end

    context '"語り部"' do
      subject { '語り部' }
      it { should_not match(table_re) }
    end
  end

  describe '#get_value_from (private)' do
    shared_examples 'get_first_of' do |table|
      subject { rg.get_value_from(table) }
      it { should eq(rg_data[table].first) }
    end

    context 'hiragana' do
      include_examples 'get_first_of', 'hiragana'
    end

    context 'hiragana2' do
      include_examples 'get_first_of', 'hiragana2'
    end

    context 'HA06event' do
      include_examples 'get_first_of', 'HA06event'
    end

    context '存在しない表の名前が指定される場合' do
      it do
        expect { rg.get_value_from('none') }.to(
          raise_error RGRB::Plugin::RandomGenerator::TableNotFound
        )
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
        freq = Hash[
          rg_data[table].map { |s| [s, 0] }
        ]

        1000.times do
          freq[rg.get_value_from(table)] += 1
        end

        expect(freq.each_value.all? { |n| (71..129).include?(n) }).to(
          be true
        )
      end
    end
  end

  describe '#replace_var_with_value (private)' do
    shared_examples 'correctly replaced' do |root_table, result|
      it %Q("#{result}" に置換される) do
        from = rg_data[root_table].first
        expect(rg.replace_var_with_value(from, root_table)).to eq(result)
      end
    end

    shared_examples 'raise error' do |root_table, error_class|
      it do
        from = rg_data[root_table].first
        expect { rg.replace_var_with_value(from, root_table) }.to(
          raise_error error_class
        )
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
