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

    context '存在しない表の名前が指定された場合' do
      it 'TableNotFound エラーが発生する' do
        expect { generator.send(:get_value_from, 'none') }.
          to raise_error(RGRB::Plugin::RandomGenerator::TableNotFound)
      end
    end

    context '最初に非公開の表から引こうとした場合' do
      it 'PrivateTable エラーが発生する' do
        expect { generator.send(:get_value_from, 'HA06pretty', true) }.
          to raise_error(RGRB::Plugin::RandomGenerator::PrivateTable)
      end
    end

    context 'hiraganarand' do
      # 要素数 10 の表から 100000 回取得したときに偏りが
      # ないことをカイ二乗検定で確かめる
      it '各値が偏りなく出る' do
        table = 'hiraganarand'
        data = generator.
          instance_variable_get(:@table)['hiraganarand'].
          instance_variable_get(:@values)
        freq = {}

        # 頻度を入れるハッシュを初期化する
        data.each do |value|
          freq[value] = 0
        end

        n_gets = 100_000
        n_gets.times do
          freq[generator.send(:get_value_from, table)] += 1
        end

        # カイ二乗値を求める
        expected_count = n_gets.to_f / data.length
        chi2 = freq.
          each_value.
          map { |count| (count - expected_count)**2 / expected_count }.
          reduce(0, :+)

        expect(chi2).to be <= 23.5894 # 自由度 9、有意水準 0.5%
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
      error_class_name = error_class.name.split('::').last
      it "#{error_class_name} エラーが発生する" do
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
        'correctly replaced',
        'self',
        '!!!!!!!!!!(...)'
      )
    end
  end
end
