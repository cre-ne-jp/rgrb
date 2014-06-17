# encoding: utf-8

==begin
irc.cre.jp系IRCサーバ群の「ランダムジェネレータ」用IRCボット
MySQLからデータを読み込みランダムジェネレートします。




==end

module rgrb
	@mysql = nil
	
	def initialize()
		# MySQL接続
		@mysql = Mysql::Client.new(CONFIG[:mysql])
		#initdb()	# テーブルの初期化はCRONとIRC接続時・手動コマンド発行時のみ
	end

	def initdb()
		# MySQL内のコマンド一覧テーブルを更新する
	
	end


end



puts basicdice(2, 6)

