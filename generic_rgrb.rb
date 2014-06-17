# encoding: utf-8

==begin
irc.cre.jp系IRCサーバ群の「汎用ランダムジェネレータ "rgrb"」
MySQLからデータを読み込みランダムジェネレートします。

MySQL接続ライブラリ: mysql2-cs-bind
http://d.hatena.ne.jp/tagomoris/20120420/1334911716
==end

require 'config'
require 'mysql2-cs-bind'

class generic_rgrb
	Version		= 1.0
	Help		= nil

	@mysql		= nil


	def initialize()
		# 全モードで使うプラグインの読み込み
		loadPlugin(CONFIG[:plugin][:list])
		
		
	end

	def loadPlugin(plugin_l)
		# プラグインの読み込みとインクルードを行なう
		plugin_l.each do |plugin_n|
			file_n = './plugins/' << plugin_n << '.rb'
			if FileTest.exist?(file_n) then
				require file_n
				include file_n
				${file_n}.initialize()
			end
		end
	end


end