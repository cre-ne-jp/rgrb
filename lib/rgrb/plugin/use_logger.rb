# vim: fileencoding=utf-8

require 'lumberjack'

module RGRB
  module Plugin
    # Generator でロガーを使う場合に利用するモジュール。
    #
    # Generator でロガーを使うときは Generator でこのモジュールを
    # include し、 +initialize()+ で +prepare_default_logger()+ を、
    # +configure()+ で +set_logger()+ をそれぞれ呼ぶ。
    module UseLogger
      # ロガーを返す
      #
      # Generator からログ出力を行うときは、以下のようにこの属性から
      # ロガーを得てそのメソッド（ +debug()+ 等）を呼び出すようにする。
      #
      #   def some_method
      #     logger.debug('Test')
      #     # 処理
      #   end
      attr_reader :logger

      # 標準のロガーを準備する
      #
      # include 元の +initialize()+ でこのメソッドを呼ぶようにする。
      # @return [self]
      def prepare_default_logger
        @logger = Lumberjack::Logger.new($stdout, progname: self.class.to_s)
        self
      end

      # 設定を読み込んでロガーを設定する
      #
      # include 元の +configure()+ でこのメソッドを呼ぶようにする。
      # +config_data[ :logger ]+ が +nil+ でなければそれをロガーとして
      # 使うように設定する。
      # @param [Hash] config_data 設定データ
      # @return [true] 新しいロガーが使用されるように設定された場合
      # @return [false] ロガーに変更がない場合
      def set_logger(config_data)
        return false unless config_data[:logger]

        @logger = config_data[:logger]
        true
      end
    end
  end
end
