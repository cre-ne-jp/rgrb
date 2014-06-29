# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module Plugin
    # hello を返すプラグイン
    class Hello
      include Cinch::Plugin

      # .hello にマッチ
      match /hello$/, method: :hello

      # NOTICE で hello を返す
      def hello(m)
        m.channel.notice "Hello, #{m.user.nick}"
      end
    end
  end
end
