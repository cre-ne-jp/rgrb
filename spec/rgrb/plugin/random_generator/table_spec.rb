# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'date'
require 'rgrb/plugin/random_generator/table'

describe RGRB::Plugin::RandomGenerator::Table do
  shared_examples 'a table' do
    let(:table) do
      described_class.parse_yaml(
        File.read("#{File.dirname(__FILE__)}/data/#{name}.yaml")
      )
    end

    describe '#name' do
      subject { table.name }
      it { should eq(name) }
    end

    describe '@values' do
      subject { table.instance_variable_get(:@values) }
      it { should eq(values) }
    end

    describe '#description' do
      subject { table.description }
      it { should eq(description) }
    end

    describe '#added' do
      subject { table.added }
      it { should eq(added) }
    end

    describe '#modified' do
      subject { table.modified }
      it { should eq(modified) }
    end

    describe '#public?' do
      subject { table.public? }
      it { should be(is_public) }
    end

    describe '#author' do
      subject { table.author }
      it { should eq(author) }
    end

    describe '#license' do
      subject { table.license }
      it { should eq(license) }
    end
  end

  context 'hiragana' do
    include_examples 'a table' do
      let(:name) { 'hiragana' }
      let(:values) { %w(あ) }
      let(:description) { 'ひらがな46文字の中から一つ選びます。' }
      let(:added) { Date.new(2014, 12, 15) }
      let(:modified) { Date.new(2014, 12, 20) }
      let(:is_public) { true }
      let(:author) { 'sf' }
      let(:license) { 'NONE' }
    end
  end

  context 'HA06pretty' do
    include_examples 'a table' do
      let(:name) { 'HA06pretty' }
      let(:values) { %w(ちいさな%%animal%%) }
      let(:description) { '語り部「狭間さまよえるもの達：現代オカルトファンタジー」に登場する可愛いものを選びます。' }
      let(:added) { Date.new(2014, 12, 15) }
      let(:modified) { Date.new(2014, 12, 20) }
      let(:is_public) { false }
      let(:author) { 'sf' }
      let(:license) { 'NONE' }
    end
  end
end
