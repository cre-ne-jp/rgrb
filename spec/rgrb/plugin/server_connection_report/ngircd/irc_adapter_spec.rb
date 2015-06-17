# vim: fileencoding=utf-8

require_relative '../../../../spec_helper'
require 'rgrb/plugin/server_connection_report/ngircd/irc_adapter'

describe RGRB::Plugin::ServerConnectionReport::Ngircd::IrcAdapter do
  describe 'REGISTERED_RE' do
    shared_examples 'registered' do |server|
      context(server) do
        let(:message) { %!Server "#{server}" registered (via ...).! }

        it 'マッチする' do
          expect(message).to match(described_class::REGISTERED_RE)
        end

        it 'ホスト名を抜き出せる' do
          m = message.match(described_class::REGISTERED_RE)
          expect(m[1]).to eq(server)
        end
      end
    end

    servers = [
      'irc.cre.ne.jp',
      'irc.kazagakure.net',
      't-net.xyz',
      'irc.r-roman.net'
    ]

    servers.each do |server|
      include_examples 'registered', server
    end
  end
end
