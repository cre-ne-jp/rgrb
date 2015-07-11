# vim: fileencoding=utf-8

require 'cinch'
require 'socket'
require 'pp'

module RGRB
  module Plugin
    # MAP コマンド結果保存プラグイン
    module StatusOutput
      # MapOutput の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'StatusOutput')
        timer(5, method: :request_map)
#        match(/map/, method: :request_map)
        listen_to(:'015', method: :receive_map)

        def initialize(*args)
          super

          @servername = {
            'services.cre.jp' => 'services',
            'irc.cre.jp' => 'cre',
            'irc.kazagakure.net' => 'kazagakure',
            'irc.r-roman.net' => 'r-roman',
            'irc.egotex.net' => 'egotex',
            'irc.sougetu.net' => 'sougetu',
            't-net.xyz' => 't-net'
          }
        end

        def request_map
          host = 'irc.cre.jp'
          port = 6666
          p 'Socket Open'
          daemon_socket = TCPSocket.open(host, port)
          daemon_socket.write("nick RGRB-requestmap\r\n")
          daemon_socket.write("user RGRB 0 0 :\r\n")
          daemon_socket.write("map\r\n")
          daemon_socket.write("quit\r\n")
          daemon_socket.close
          p 'Socket Close'
        end

        def receive_map(m)
          #get_time = m.time
          map_data = m.params[1]
          map_data.match(
            %r{[\|`\- ]*([\w\.\-]+)\[\d\d\w\] -+ \| Users:\s+(\d+)}
          ) { |md|
            print("ircmap_#{@servername[md[1]]}.value #{md[2]}\n")
          }
        end
      end
    end
  end
end
