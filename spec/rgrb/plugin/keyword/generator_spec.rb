# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/keyword/generator'

describe RGRB::Plugin::Keyword::Generator do
  let(:generator) do
    described_class.
      new.
      configure('AmazonAssociateID' => 'koubou-22')
  end

  describe '#cre_search' do
    let(:base_url) { 'https://log.irc.cre.jp/keywords/' }

    shared_examples 'a Cre search' do
      let(:expected_message) do
        "キーワード一覧の #{expected_url} をどうぞ♪"
      end

      subject { generator.cre_search(keyword) }
      it { should eq(expected_message) }
    end

    context '"test"' do
      include_examples 'a Cre search' do
        let(:keyword) { 'test' }
        let(:expected_url) { "#{base_url}test" }
      end
    end

    context '"ネクロニカ"' do
      include_examples 'a Cre search' do
        let(:keyword) { 'ネクロニカ' }
        let(:expected_url) { "#{base_url}%E3%83%8D%E3%82%AF%E3%83%AD%E3%83%8B%E3%82%AB" }
      end
    end
  end

  describe '#amazon_search' do
    let(:base_url) { 'https://www.amazon.co.jp/gp/search?ie=UTF8&tag=koubou-22&keywords=' }

    shared_examples 'an Amazon search' do
      let(:expected_message) do
        "Amazon.co.jp の商品一覧から #{expected_url} をどうぞ♪"
      end

      subject { generator.amazon_search(keyword) }
      it { should eq(expected_message) }
    end

    context '"test"' do
      include_examples 'an Amazon search' do
        let(:keyword) { 'test' }
        let(:expected_url) { "#{base_url}test" }
      end
    end

    context '"ネクロニカ"' do
      include_examples 'an Amazon search' do
        let(:keyword) { 'ネクロニカ' }
        let(:expected_url) { "#{base_url}%E3%83%8D%E3%82%AF%E3%83%AD%E3%83%8B%E3%82%AB" }
      end
    end
  end
end
