# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module Plugin
    # キーワード検索プラグイン
    class ServerFailedReport
      include Cinch::Plugin

      # サーバーがリレーから切断した際のメッセージ
      FAIL_MESSAGE = '"%s"がリレーから切り離されました。'
      # サーバーがリレーした際のメッセージ
      CONNECT_MESSAGE = '"%s"がリレーしました。'

			# メッセージ出力先
			@channel_name = ''

      match(/Server "([\w\.]+)" unregistered/, method: :fail_srv)
      match(/Server "([\w\.]+)" registered/, method: :connect_srv)
			match(/roll[ 　]+([1-9]\d*)d([1-9]\d*)/i, method: :basic_dice)

			def basic_dice(m, n_dice, max)
			  m.target.notice("#{m.user.nick} -> #{n_dice}d#{max} = test")
			end


			# NOTICE でサーバー切断メッセージを出す
      # @return [void]
      def fail_srv(m, srvname)
				mes = FAIL_MESSAGE % srvname
#				@channel_name.each do |channel_name|
					Channel(@channel_name).safe_notice(mes)
#				end
      end

      # NOTICE でサーバー接続メッセージを返す
      # @return [void]
      def connect_srv(m, srvname)
				mes = CONNECT_MESSAGE % srvname
#				@channel_name.each do |channel_name|
					Channel(@channel_name).safe_notice(mes)
#				end
      end
    end
  end
end
