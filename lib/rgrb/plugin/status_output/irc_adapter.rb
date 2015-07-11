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

        # MAP コマンドの応答 (charybdis)
        listen_to(:'015', method: :map)

        # LUSERS コマンドの応答 (charybdis)
        listen_to(:'251', method: :general_datas)
        listen_to(:'252', method: :opers)
        listen_to(:'254', method: :channels)
        listen_to(:'255', method: :local_connections)
        listen_to(:'265', method: :local_users)
        listen_to(:'266', method: :global_users)

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

        def map(m)
          #get_time = m.time
          m.params[1].match(
            %r{[\|`\- ]*([\w\.\-]+)\[\d\d\w\] -+ \| Users:\s+(\d+)}
          ) { |md|
            print("ircMap_#{@servername[md[1]]}.value #{md[2]}\n")
          }
        end

        def general_datas(m)
          m.params[1].match(
            %r{There are (\d+) users and (\d+) invisible on (\d+) servers}
          ) { |md|
            #print("ircGlobalUsers.value #{md[1].to_i + md[2].to_i}\n")
            print("ircGlobalServers.value #{md[3]}\n")
          }
        end

        def opers(m)
          print("ircOpers.value #{m.params[1]}\n")
        end

        def channels(m)
          print("ircChannels.value #{m.params[1]}\n")
        end

        def local_connections(m)
          m.params[1].match(
            %r{I have (\d+) clients and (\d+) servers}
          ) { |md|
            #print("ircLocalClients.value #{md[1]}\n")
            print("ircLocalServers.value #{md[2]}\n")
          }
        end

        def local_users(m)
          print("ircLocalCurrentUsers.value #{m.params[1]}\n")
          print("ircLocalMaxUsers.value #{m.params[2]}\n")
        end

        def global_users(m)
          print("ircGlobalCurrentUsers.value #{m.params[1]}\n")
          print("ircGlobalMaxUsers.value #{m.params[2]}\n")
        end
      end
    end
  end
end
