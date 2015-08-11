# vim: fileencoding=utf-8

require_relative '../../../../spec_helper'
require 'rgrb/plugin/server_connection_report/charybdis/irc_adapter'

describe RGRB::Plugin::ServerConnectionReport::Charybdis::IrcAdapter do
  servers = [
    'irc.cre.jp',
    'irc.cre.ne.jp',
    'irc.egotex.net',
    'irc.kazagakure.net',
    'irc.r-roman.net',
    'irc.sougetu.net',
    'irc.trpg.net',
    't-net.xyz'
  ]

  describe 'NETJOIN_RE' do
    shared_examples 'netjoin' do |server|
      context(server) do
        let(:message) { "*** Notice -- Netjoin irc.cre.ne.jp <-> #{server} (0S 0C)" }

        it 'マッチする' do
          expect(message).to match(described_class::NETJOIN_RE)
        end

        it 'ホスト名を抜き出せる' do
          m = message.match(described_class::NETJOIN_RE)
          expect(m[1]).to eq(server)
        end
      end
    end

    servers.each do |server|
      include_examples 'netjoin', server
    end
  end

  describe 'NETSPLIT_RE' do
    shared_examples 'netsplit' do |server|
      context(server) do
        let(:comment) { 'some comment' }
        let(:message) do
          "*** Notice -- Netsplit irc.cre.ne.jp <-> #{server} (0S 0C) (#{comment})"
        end

        it 'マッチする' do
          expect(message).to match(described_class::NETSPLIT_RE)
        end

        it 'ホスト名を抜き出せる' do
          m = message.match(described_class::NETSPLIT_RE)
          expect(m[1]).to eq(server)
        end

        it 'コメントを抜き出せる' do
          m = message.match(described_class::NETSPLIT_RE)
          expect(m[2]).to eq(comment)
        end
      end
    end

    servers.each do |server|
      include_examples 'netsplit', server
    end
  end
end
