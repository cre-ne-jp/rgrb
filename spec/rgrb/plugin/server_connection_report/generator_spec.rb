# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/server_connection_report/generator'

describe RGRB::Plugin::ServerConnectionReport::Generator do
  let(:generator) { described_class.new }

  describe '#registered' do
    shared_examples 'registered' do
      subject { generator.registered(server) }
      it { should eq(%Q("#{server}" がネットワークに参加しました。)) }
    end

    context 'irc.cre.jp' do
      include_examples 'registered' do
        let(:server) { 'irc.cre.jp' }
      end
    end

    context 'irc.kazagakure.net' do
      include_examples 'registered' do
        let(:server) { 'irc.kazagakure.net' }
      end
    end
  end

  describe '#unregistered' do
    shared_examples 'unregistered' do
      subject { generator.unregistered(server) }
      it { should eq(%Q("#{server}" がネットワークから切断されました。)) }
    end

    context 'irc.cre.jp' do
      include_examples 'unregistered' do
        let(:server) { 'irc.cre.jp' }
      end
    end

    context 'irc.kazagakure.net' do
      include_examples 'unregistered' do
        let(:server) { 'irc.kazagakure.net' }
      end
    end
  end
end
