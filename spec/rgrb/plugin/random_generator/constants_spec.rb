# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/random_generator/constants'

describe RGRB::Plugin::RandomGenerator do
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
end
