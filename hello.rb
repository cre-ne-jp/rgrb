#!/usr/bin/env ruby
# vim: fileencoding=utf-8

require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    # c.server = '' # IRC サーバ
    # c.port = 6667
    # c.password = '' # パスワード
    c.nick = c.realname = c.user = 'hello_ocha'
  end

  on :message, "hello" do |m|
    m.channel.notice "Hello, #{m.user.nick}"
  end
end

bot.start
