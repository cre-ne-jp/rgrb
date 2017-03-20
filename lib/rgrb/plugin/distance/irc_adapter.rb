# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    # 直線距離管理プラグイン
    module Distance
      # Distance の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::Logging
        include ConfigurableAdapter

        set(plugin_name: 'Distance')
        listen_to(:topic, method: :topic)
        
        self.prefix = '.distance'
        match(/ ([左右]),([\d]{1,2})(?:,(.*^[ 　])|$)/, method: :move)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          prepare_generator
        end

        # Topic が設定されたとき
        def topic(m, topic)
          @generator.analize(topic)
        end

        # コマを移動させる
        # @param [Cinch::Message] m
        # @param [String] direction 移動方向
        # @param [String] distance 移動距離
        # @param [String] segment 移動させるコマ
        # @return [void]
        def move(m, direction, distance, segment = nil)
          unless(m.target.opped?(bot.nick))
            send('チャンネルオペレータ権がない場合、作動できません')
            return
          end

          unless(@generator.channels.include?(m.channel.name))
            send('このチャンネルでは直線距離を管理していません')
            send('有効な Topic を再設定してください')
            return
          end

          # コマの名前が省略された場合、発言者の NICK から頭2文字を切り出す
          if(segment.nil?)
            segment = m.user.nick[0..1]
          end

          distance = distance.to_i
          distance = case direction
            when '左'
              distance * -1
            when '右'
              distance
            else
              send('方向を指定してください')
              return
            end
          new_topic = @generator.move(m.channel.name, segment, distance)
        end

        # IRC にメッセージを送信する
        def send(text)
          m.target.send(text, true)
          log_(text)
        end
      end
    end
  end
end
