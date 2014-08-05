require_relative '../../spec_helper'
require 'rgrb/plugin/random_generator'

describe RGRB::Plugin::RandomGenerator::DetermineNeedToRecGet do
  let(:some_class) do
    k = Class.new
    k.class_eval do
      include RGRB::Plugin::RandomGenerator::DetermineNeedToRecGet

      def det(prefix)
        determine_need_to_rec_get(prefix)
      end
    end

    k
  end
  let(:obj) { some_class.new }

  describe '#determine_need_to_rec_get (private)' do
    context 'R' do
      subject { obj.det('R') }
      it { should eq(true) }
    end

    context 'N' do
      subject { obj.det('N') }
      it { should eq(false) }
    end

    context 'その他' do
      it do
        expect { obj.det('') }.to raise_error
        expect { obj.det('A') }.to raise_error
      end
    end
  end
end

describe RGRB::Plugin::RandomGenerator::Variable do
  shared_examples 'a Variable' do
    let(:var) { described_class.new(name) }
    let(:var_set) do
      v = described_class.new(name)
      v.value = value
      v
    end

    describe '#name' do
      subject { var.name }
      it { should eq(name) }
    end

    describe '#value' do
      context '生成直後' do
        subject { var.value }
        it { should be_nil }
      end

      context '値設定後' do
        subject { var_set.value }
        it { should eq(value[1..-1]) }
      end
    end

    describe '#value=' do
      context '再帰取り出しが必要か判断できない場合' do
        it do
          expect { var.value = 'test' }.to raise_error(ArgumentError)
        end
      end
    end

    describe '#needs_recursive_get?' do
      context '生成直後' do
        it do
          expect { var.needs_recursive_get? }.to raise_error
        end
      end

      context '値設定後' do
        it do
          case value[0]
          when 'R'
            expect(var_set.needs_recursive_get?).to eq(true)
          when 'N'
            expect(var_set.needs_recursive_get?).to eq(false)
          end
        end
      end
    end
  end

  context '%%hiragana%%' do
    let(:name) { 'hiragana' }
    let(:value) { 'Nあ' }

    include_examples 'a Variable'
  end

  context '%%hiragana2%%' do
    let(:name) { 'hiragana2' }
    let(:value) { 'R%%hiragana%%%%hiragana%%' }

    include_examples 'a Variable'
  end
end
