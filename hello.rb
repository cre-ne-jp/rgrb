#!/usr/bin/env ruby
# vim: fileencoding=utf-8

require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.cre.ne.jp'
    c.channels = [] # テスト用チャンネル
    c.nick = 'hello_ocha'
    c.realname = c.nick
  end

  on :message, "hello" do |m|
    m.channel.notice "Hello, #{m.user.nick}"
  end
end

bot.start
