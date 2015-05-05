# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # ServerConnectionReport の出力テキスト生成器
      class Generator
        # サーバがネットワークに参加した際のメッセージを返す
        # @param [String] server サーバ名
        # @param [String] message メッセージ
        # @return [String]
        def joined(server, message = nil)
          common_part = "!! #{server} がネットワークに参加しました"
          if message
            "#{common_part} (#{message})"
          else
            common_part
          end
        end

        # サーバがネットワークから切断された際のメッセージを返す
        # @param [String] server サーバ名
        # @param [String] message メッセージ
        # @return [String]
        def disconnected(server, message = nil)
          common_part = "!! #{server} がネットワークから切断されました"
          if message
            "#{common_part} (#{message})"
          else
            common_part
          end
        end
      end
    end
  end
end
