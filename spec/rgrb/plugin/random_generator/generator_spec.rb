# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'date'
require 'lumberjack'
require 'rgrb/plugin/random_generator/generator'

describe RGRB::Plugin::RandomGenerator::Generator do
  let(:generator) do
    g = described_class.new
    g.load_data!("#{__dir__}/data/*.yaml")

    g
  end

  describe '#desc' do
    context 'hiragana' do
      subject { generator.desc('hiragana') }
      it { should eq('ひらがな46文字の中から一つ選びます。') }
    end

    context 'HA06event' do
      subject { generator.desc('HA06event') }
      it { should eq('語り部「狭間さまよえるもの達：現代オカルトファンタジー」で物語のきっかけとなる事件を作ります。') }
    end

    context '存在しない表の名前が指定された場合' do
      it 'TableNotFound エラーが発生する' do
        expect { generator.desc('none') }.
          to raise_error(RGRB::Plugin::RandomGenerator::TableNotFound)
      end
    end
  end

  describe '#japanese_date (private)' do
    context '2014-12-31' do
      subject { generator.send(:japanese_date, Date.new(2014, 12, 31)) }
      it { should eq('2014年12月31日') }
    end

    context '2015-04-01' do
      subject { generator.send(:japanese_date, Date.new(2015, 4, 1)) }
      it { should eq('2015年4月1日') }
    end
  end

  describe '#info' do
    context 'hiragana' do
      subject { generator.info('hiragana') }
      it { should eq('「hiragana」の作者は sf さんで、2014年12月15日 に追加されましたの。最後に更新されたのは 2014年12月20日 ですわ。ひらがな46文字の中から一つ選びます。') }
    end

    context 'hiragana-no-modified' do
      subject { generator.info('hiragana-no-modified') }
      it { should eq('「hiragana-no-modified」の作者は ocha さんで、2015年4月6日 に追加されましたの。ひらがな46文字の中から一つ選びます。') }
    end

    context '存在しない表の名前が指定された場合' do
      it 'TableNotFound エラーが発生する' do
        expect { generator.info('none') }.
          to raise_error(RGRB::Plugin::RandomGenerator::TableNotFound)
      end
    end
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
      it '100 回取り出したとき、値がすべて同じではない' do
        table = 'hiraganarand'
        results = Array.new(100) do
          generator.send(:get_value_from, table)
        end

        expect(results.uniq.length).to be > 1
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
