# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/irc_adapter_methods'

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
          include ServerConnectionReport::IrcAdapterMethods

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          NETJOIN_RE =
            /jointest #{HOSTNAME_RE} <-> (#{HOSTNAME_RE})/o
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          NETSPLIT_RE =
            /splittest #{HOSTNAME_RE} <-> (#{HOSTNAME_RE}) \(.+?\) \((.+)\)/o

          set(plugin_name: 'ServerConnectionReport::Test')
          self.prefix = ''

          match(NETJOIN_RE, method: :joined)
          match(NETSPLIT_RE, method: :disconnected)

          # サーバーへの接続が完了したときの処理
          listen_to(:'002', method: :set_connection_info)

          # IRC アダプタを初期化する
          def initialize(*)
            super

            config_data = config[:plugin]
            @test_channel = config_data['TestChannel'] || '#irc_test'

            prepare_generators
          end

          # ネットワークにあるサーバが参加したときの処理
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          #
          # サーバのネットワークへの参加を NOTICE で通知する。
          # メール送信の設定が行われている場合は、メールの送信も行う。
          def joined(m, server)
            notice_joined(m, server) if m.channel == @test_channel
          end

          # ネットワークからあるサーバが切断されたときの処理
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @param [String] comment コメント
          # @return [void]
          #
          # サーバのネットワークからの切断を NOTICE で通知する。
          # メール送信の設定が行われている場合は、メールの送信も行う。
          def disconnected(m, server, comment)
            if m.channel == @test_channel
              notice_disconnected(m, server, comment)
            end
          end
        end
      end
    end
  end
end
