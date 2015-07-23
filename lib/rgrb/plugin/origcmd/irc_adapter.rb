# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/origcmd/constants'
require 'rgrb/plugin/origcmd/generator'

module RGRB
  module Plugin
    module Origcmd
      # Origcmd の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'Origcmd')
        self.prefix = '.origcmd '
        match(/create[ 　]+(.+)/, method: :create)
        match(/remove (#{CMD_RE})(.*)/, method: :remove)
        match(/show (#{CMD_RE})/, method: :show)
        match(/edit (#{CMD_RE}) (#{CMD_RE})[ 　]+(.+)/, method: :edit)
        
        match(/\+[ 　]+(.+)/, method: :create, :prefix => '.oc')
        match(/- (#{CMD_RE})(.*)/, method: :remove, :prefix => '.oc')
        match(/\? (#{CMD_RE})/, method: :show, :prefix => '.oc')
        
        match(/(#{CMD_RE})(.*)/i, method: :cmdcall, :prefix => '&')

        def initialize(*args)
          super
          prepare_generator
        end

        # オリジナルコマンドを設定する
        # .origcmd create CMDNAME DELKEY コマンドの応答
        # @return [void]
        def create(m, args)
          nick = m.user.nick
          channel = m.channel.to_s
          cmdname, delkey, reply = args.split(/[ 　]+/, 3)

          result = 
            if cmdname == nil
              'cmdname is empty'
            elsif delkey == nil or delkey == ''
              'delkey is empty'
            elsif reply == nil or reply == ''
              'reply is empty'
            else
              @generator.create(nick, channel, cmdname, delkey, reply)
            end
p result
          result.each_line do |line|
            message = "origcmd[#{nick}]<CREATE>: #{line.chomp}"
p message
            m.target.send(message, true)
            #log_notice(m.target, message)
          end
        end

        # オリジナルコマンドを削除する
        # .origcmd remove CMDNAME DELKEY
        # @return [void]
        def remove(m, cmdname, args)
          delkey = args.split(/[ 　]+/).at(1)
          message = 
            if delkey == nil or delkey == ''
              '[error] 削除キーが入力されていません'
            else
              "origcmd[#{m.user.nick}]<REMOVE>: #{@generator.remove(cmdname, delkey)}"
            end
          m.target.send(message, true)
          #log_notice(m.target, message)
        end

        # オリジナルコマンドの設定内容を表示する
        # .origcmd show CMDNAME
        # @return [void]
        def show(m, cmdname)
          message = "origcmd[#{m.user.nick}]<SHOW>: #{@generator.show(cmdname)}"
          m.target.send(message, true)
          #log_notice(m.target, message)
        end

        # オリジナルコマンドを編集する(上書き登録する)
        # .origcmd edit CMDNAME DELKEY コマンドの応答
        # @return [void]
        def edit(m, cmdname, delkey, reply)
          nick = m.user.nick
          channel = m.channel.to_s
          @generator.edit(nick, channel, cmdname, delkey, reply).each_line do |line|
            message = "origcmd[#{m.user.nick}]<EDIT>: #{line.chomp}"
            m.target.send(message, true)
            #log_notice(m.target, message)
          end
        end

        def cmdcall(m, cmdname, args)
          args.slice!(/[ 　]+/)
          return until result = @generator.cmdcall(m, cmdname, args)
          result.each_line do |line|
            message = "&#{cmdname}[#{m.user.nick}]: #{line.chomp}"
            m.target.send(message, true)
            #log_notice(m.target, message)
          end
        end
      end
    end
  end
end
