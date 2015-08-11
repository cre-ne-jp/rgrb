# vim: fileencoding=utf-8

require_relative '../../../../spec_helper'
require 'rgrb/plugin/server_connection_report/atheme_services/irc_adapter'

describe RGRB::Plugin::ServerConnectionReport::AthemeServices::IrcAdapter do
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

  describe 'SERVER_ADD_RE' do
    shared_examples 'server_add' do |server|
      context(server) do
        let(:message) { "server_add(): #{server}" }

        it 'マッチする' do
          expect(message).to match(described_class::SERVER_ADD_RE)
        end

        it 'ホスト名を抜き出せる' do
          m = message.match(described_class::SERVER_ADD_RE)
          expect(m[1]).to eq(server)
        end
      end
    end

    servers.each do |server|
      include_examples 'server_add', server
    end
  end

  describe 'SERVER_DELETE_RE' do
    shared_examples 'server_delete' do |server|
      context(server) do
        let(:message) do
          "server_delete(): #{server}"
        end

        it 'マッチする' do
          expect(message).to match(described_class::SERVER_DELETE_RE)
        end

        it 'ホスト名を抜き出せる' do
          m = message.match(described_class::SERVER_DELETE_RE)
          expect(m[1]).to eq(server)
        end
      end
    end

    servers.each do |server|
      include_examples 'server_delete', server
    end
  end
end
