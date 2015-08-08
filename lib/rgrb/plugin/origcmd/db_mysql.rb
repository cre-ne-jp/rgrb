# vim: fileencoding=utf-8

require 'mysql2'
require 'active_record'

module RGRB
  module Plugin
    module Origcmd
      class Database
        # MySQL データベースを開く
        # @param [Hash] options DB に関する設定
        # @option options [String] :data_path データファイルのパス
        # @option options [String] :dbname_prefix データベース名の接頭詞
        # @option options [String] :config データベースに関する設定ファイルでの指定
        # @option options:config [String] Type データベースの種類
        # @option options:config [String] Connection 使用する DB 接続設定名
        # @option options:config:#{Connection} [String] ActiveRecord に与える接続設定本体
        # @return [true]
        def initialize(options)
          connection_config = options[:config][options[:config]['Connection']]
          connection_config['adapter'] = 'mysql2'
          ActiveRecord::Base.establish_connection(connection_config)
          true
        end

        # MySQL データベースへ書き込む
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
          db = Origcmds.new(data)
          db.save
        end

        # MySQL データベースから指定されたコマンド名のデータを読み込む
        # @param [String] cmdname 読み込むコマンド名
        # @return [Hash]
        def read(cmdname)
          db = Origcmds.find_by(cmdname: cmdname)
          db

          data = JSON.parse(@dbm[cmdname], {:symbolize_names => true})
          data[:date] = Date.parse(data[:date])

          data
        end

        # MySQL データベースから指定されたコマンド名のデータを削除する
        # @param [String] cmdname
        # @return [nil]
        def remove(cmdname)
          @dbm.delete(cmdname)
          nil
        end

        # MySQL データベースに指定したコマンド名が登録されているか調べる
        # @param [String] cmdname
        # @return [Boolean]
        def cmd_exist?(cmdname)
          @dbm.has_key?(cmdname)
        end

        class Origcmds < ActiveRecord::Base
        end
      end
    end
  end
end
