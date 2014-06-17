#!/usr/bin/ruby -Ku
# encoding: utf-8

==begin
irc.cre.jp系IRCサーバ群の「ランダムジェネレータ」用IRCボット
汎用のダイスボットで、指定されたプラグインを読み込んで待機します。


MySQL接続ライブラリ: mysql2-cs-bind
http://d.hatena.ne.jp/tagomoris/20120420/1334911716


==end



class ircbot < generic_rgrb

	def initialize()
		self.initdb()
		loadPlugin(CONFIG[:irc][:plugins])

	end

end
