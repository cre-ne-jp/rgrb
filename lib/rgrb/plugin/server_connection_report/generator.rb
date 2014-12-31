# vim: fileencoding=utf-8

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # ServerConnectionReport の出力テキスト生成器
      class Generator
        # サーバがネットワークに参加した際のメッセージを返す
        # @param [String] server サーバ名
        # @return [String]
        def registered(server)
          %Q("#{server}" がネットワークに参加しました。)
        end

        # サーバがネットワークから切断された際のメッセージを返す
        # @param [String] server サーバ名
        # @return [String]
        def unregistered(server)
          %Q("#{server}" がネットワークから切断されました。)
        end
      end
    end
  end
end
