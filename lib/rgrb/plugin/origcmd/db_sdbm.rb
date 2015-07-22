# vim: fileencoding=utf-8

require 'sdbm'
require 'json'

module RGRB
  module Plugin
    module Origcmd
      class Database

        def initialize
          dbm = SDBM.open(filename)
        end

        # SDBM データベースへ書き込む
        # @param [String] nick 
        # @param [String] channel
        # @param [String] cmdname
        # @param [String] delkey
        # @param [String] reply
        # @return [Boolean]
        def write(nick, channel, cmdname, delkey, reply)
          data = {
            nick: nick,
            channel: channel,
            cmdname: cmdname,
            delkey: delkey,
            reply: reply,
            date: Date.today
          }

          dbm[cmdname] = JSON.dump(data)
          true
        end

        # SDBM データベースから指定されたコマンド名のデータを読み込む
        # @param [String] cmdname 読み込むコマンド名
        # @return [Hash]
        def read(cmdname)
          data = JSON.parse(dbm[cmdname], {:symbolize_names => true})
          data[:date] = Date.parse(data[:date])

          data
        end

        # SDBM データベースから指定されたコマンド名のデータを削除する
        # @param [String] cmdname
        # @return [nil]
        def remove(cmdname)
          dbm.delete(cmdname)
          nil
        end

        # SDBM データベースに指定したコマンド名が登録されているか調べる
        # @param [String] cmdname
        # @return [Boolean]
        def cmd_exist?(cmdname)
          dbm.has_key?(cmdname)
        end

      end
    end
  end
end
