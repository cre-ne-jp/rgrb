#!/usr/bin/ruby -Ku
# encoding: utf-8

=begin
汎用ランダムジェネレータ 設定ファイル
このファイルは "generic_rgrb.rb" から呼び出されます
=end


### Global Settings ###

# MySQL connect
$CONFIG[:mysql][:host]		= 'localhost'
$CONFIG[:mysql][:username]	= 'rgrb'
$CONFIG[:mysql][:password]	= ''
$CONFIG[:mysql][:database]	= 'rgrb'

# Load Plugin list
$CONFIG[:plugins][:list]		= 'rgrb'
#$CONFIG[:mode][:plugin]
$CONFIG[:irc][:plugin]		= 'keywords', 'roll'

# Plugins Settings
#$CONFIG[:plugins][:rgrb]		=


### IRC Settings ###
$CONFIG[:irc][:host]		=
$CONFIG[:irc][:nick]		=
$CONFIG[:irc][:user]		=
$CONFIG[:irc][:pass]		= nil


### HTML Settings ###



