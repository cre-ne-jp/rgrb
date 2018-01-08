# vim: fileencoding=utf-8

require 'cinch'
require 'pp'

require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/generator'
require 'rgrb/plugin/server_connection_report/common_disposal'

module RGRB
  module Plugin
    module ServerConnectionReport
      # Test 用サーバリレー監視プラグイン。
      #
      # サーバの接続状態が変化したときに Oper ユーザーに送信される PRIVMSG
      # を解析する。
      # したがって、基本的にボットが Oper であることが必要である。
      #
      # 送信元を指定するオプション AllowedSenders にサーバアドレスを追加
      # し、受信するメッセージを絞る。
      module Test
        # ServerConnectionReport::Test の IRC アダプター
        class IrcAdapter
          include Cinch::Plugin
          include ServerConnectionReport::CommonDisposal

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          NETJOIN_RE =
            /jointest #{HOSTNAME_RE} <-> (#{HOSTNAME_RE})/o
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          NETSPLIT_RE =
            /splittest #{HOSTNAME_RE} <-> (#{HOSTNAME_RE}) \(.+?\) \((.+)\)/o

          set(plugin_name: 'ServerConnectionReport::Test')
          self.prefix = ''

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          match(NETJOIN_RE, method: :joined)
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          match(NETSPLIT_RE, method: :disconnected)
          # サーバーへの接続が完了したときに情報を集める
          listen_to(:'002', method: :connected)

          def initialize(*)
            super

            config_data = config[:plugin]
            @channels_to_send = config_data['ChannelsToSend'] || []
            @testchannel = config_data['TestChannel'] || '#irc_test'

            @generator = Generator.new
            @generator.root_path = config[:root_path]
            @generator.configure(config[:plugin])
          end

          # サーバ接続メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def joined(m, server)
            if m.channel == @testchannel
              log_incoming(m)
              sleep 1
              notice_on_each_channel(@generator.joined(server, m.time))
            end
          end

          # サーバ切断メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @param [String] comment コメント
          # @return [void]
          def disconnected(m, server, comment)
            if m.channel == @testchannel
              log_incoming(m)
              notice_on_each_channel(
                @generator.disconnected(server, m.time, comment)
              )
            end
          end

          # サーバーへの接続が完了したとき、情報を集める
          # @param [Cinch::Message] m メッセージ
          # @return [void]
          def connected(m)
            _connected(m)
          end
        end
      end
    end
  end
end
