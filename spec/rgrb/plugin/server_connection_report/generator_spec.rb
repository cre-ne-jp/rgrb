# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/server_connection_report/generator'

describe RGRB::Plugin::ServerConnectionReport::Generator do
  let(:generator) { described_class.new }

  describe '#joined' do
    context 'irc.cre.jp' do
      subject { generator.joined('irc.cre.jp') }
      it { should eq('!! irc.cre.jp がネットワークに参加しました') }
    end

    context 'irc.kazagakure.net' do
      subject { generator.joined('irc.kazagakure.net', Date.new, 'connected') }
      it { should eq('!! irc.kazagakure.net がネットワークに参加しました (connected)') }
    end
  end

  describe '#disconnected' do
    context 'irc.cre.jp' do
      subject { generator.disconnected('irc.cre.jp') }
      it { should eq('!! irc.cre.jp がネットワークから切断されました') }
    end

    context 'irc.kazagakure.net' do
      subject do
        generator.disconnected(
          'irc.kazagakure.net',
          Date.new,
          'Remote host closed the connection'
        )
      end
      it { should eq('!! irc.kazagakure.net がネットワークから切断されました (Remote host closed the connection)') }
    end
  end
end
