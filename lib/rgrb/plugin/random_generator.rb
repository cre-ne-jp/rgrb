# vim: fileencoding=utf-8

require 'cinch'
require 'strscan'
require 'redis'
require 'redis-namespace'

module RGRB
  module Plugin
    # ランダムジェネレータプラグインのクラス
    #
    # データは Redis 上の +'rg:表名'+ という名前の集合に保存される。
    # 値には、再帰取り出しが必要かどうかによって、
    # 以下のどちらかの接頭辞が付加される。
    #
    # [+'R'+] 再帰取り出しが必要
    # [+'N'+] 再帰取り出しは不要
    #
    # 上記の接頭辞を除去してメッセージを生成する。
    class RandomGenerator
      include Cinch::Plugin
      # 再帰取り出しの必要性判定のモジュール
      module DetermineNeedToRecGet
        private

        # 接頭辞を見て再帰取り出しの必要性を判定し、返す
        # @return [Boolean] 再帰取り出しの必要性
        # @raise [ArgumentError] 再帰取り出しが必要か
        #   判断できない場合
        def determine_need_to_rec_get(prefix)
          case prefix
          when 'R'
            true
          when 'N'
            false
          else
            fail(ArgumentError, '再帰取り出しが必要か不明')
          end
        end
      end

      # 表名を表す正規表現
      TABLE_RE = /(?:[-_0-9A-Za-z]+)/
      # 変数を表す正規表現
      VARIABLE_RE = /(?:%%(#{TABLE_RE})%%)/o

      # .rg にマッチ
      match(/rg[ 　]+(#{TABLE_RE}(?: +#{TABLE_RE})*)/o, method: :rg)

      def initialize(*args)
        super

        @rgrb_root_path = config[:rgrb_root_path]
        @redis_rg = Redis::Namespace.new('rg', redis: config[:redis])

        # 表が存在するかどうかを格納する連想配列
        @exist_table = {}

        load_data
      end

      # NOTICE でジェネレート結果を返す
      # @return [void]
      def rg(m, tables_str)
        tables_str.split(' ').each do |table|
          message =
            begin
              result = get_value_from(table)
              "rg[#{m.user.nick}]<#{table}>: #{result} ですわ☆"
            rescue TableNotFound => not_found
              "rg[#{m.user.nick}]: 「#{not_found.table}」なんて" \
                '表は見つからないのですわっ。'
            rescue CircularReference => circular_reference
              "rg[#{m.user.nick}]: 表「#{circular_reference.table}」で" \
                '循環参照が起こりました。#next でご報告ください。'
            end
          m.channel.notice(message)

          sleep(1)
        end
      end

      private

      # 与えられた表名を使って DB から値を取得する
      # @param [String] table 表名
      # @return [String]
      # @raise [TableNotFound] 表が見つからなかった場合
      def get_value_from(table)
        fail(TableNotFound, table) unless @exist_table[table]

        value = @redis_rg.srandmember(table)
        value_content = value[1..-1]

        if determine_need_to_rec_get(value[0])
          get_value_recursively(value_content, table => true)
        else
          value_content
        end
      end

      # 表から値を再帰的に取得する
      # @param [String] str 変数が含まれている、表から取得した値
      # @param [Hash] getting 値を取得している表を格納するハッシュ
      # @return [String]
      # @raise [TableNotFound] 表が見つからない場合
      # @raise [CircularReference] 循環参照が起こった場合
      def get_value_recursively(str, getting)
        scanner = StringScanner.new(str)
        intermediate_expression = []
        variables = []

        # 中間表現を生成する
        until scanner.eos?
          if scanner.skip(VARIABLE_RE)
            name = scanner[1]
            fail(TableNotFound, name) unless @exist_table[name]
            fail(CircularReference, name) if getting[name]

            variable = Variable.new(name)
            intermediate_expression << variable
            variables << variable
          else
            if (char = scanner.getch)
              intermediate_expression << char
            end
          end
        end

        # Redis から値を取得する
        values = @redis_rg.pipelined do
          variables.each do |var|
            @redis_rg.srandmember(var.name)
          end
        end

        variables.zip(values).each do |var, value|
          var.value = value
        end

        # 結果を生成する
        result = intermediate_expression.map(&:to_s).join
        if variables.any?(&:needs_recursive_get?)
          variables.map(&:name).uniq.each do |var_name|
            getting[var_name] = true
          end

          get_value_recursively(result, getting)
        else
          result
        end
      end

      # 表のデータを読み込む
      # @return [void]
      def load_data
        pattern = "#{@rgrb_root_path}/data/rg/*.txt"
        Dir.glob(pattern) do |path|
          name = File.basename(path, '.txt')

          File.open(path, 'r:UTF-8') do |f|
            f.each_line do |line|
              prefix = (VARIABLE_RE =~ line) ? 'R' : 'N'
              @redis_rg.sadd(name, prefix + line.chomp)
            end
          end

          @exist_table[name] = true
        end
      end

      # 表から引いた文字列に含まれる <変数> を表すクラス
      class Variable
        include DetermineNeedToRecGet

        # 変数名
        # @return [String]
        attr_reader :name
        # 値
        # @return [String]
        attr_reader :value

        # 新しい Variable インスタンスを返す
        # @param [String] name 変数名
        def initialize(name)
          @name = name
          @value = nil

          @needs_recursive_get = nil
        end

        # 値を設定する
        #
        # 同時に「再帰取り出しが必要か」も設定される
        # @param [String] value Redis から得た値
        # @return [String] Redis から得た値
        # @raise [ArgumentError] +value+ から再帰取り出しが必要か
        #   判断できない場合
        def value=(value)
          @needs_recursive_get = determine_need_to_rec_get(value[0])
          @value = value[1..-1]
        end

        # 再帰取り出しが必要がどうかを返す
        # @return [Boolean]
        # @raise [RuntimeError] 値が設定されていない場合
        def needs_recursive_get?
          if @needs_recursive_get.nil?
            fail("変数 #{@name}: 値が設定されていません")
          end

          @needs_recursive_get
        end

        alias_method(:to_s, :value)
      end

      # 表が見つからない場合のエラーを示すクラス
      class TableNotFound < StandardError
        # 見つからなかった表名
        # @return [String]
        attr_reader :table

        # 新しい TableNotFound インスタンスを返す
        # @param [String] table 表名
        # @param [String] error_message エラーメッセージ
        def initialize(table = nil, error_message = nil)
          if !error_message && table
            error_message = "表 #{table} が見つかりません"
          end

          super(error_message)

          @table = table
        end
      end

      # 循環参照エラーを示すクラス
      class CircularReference < StandardError
        # 循環参照が起こった表名
        # @return [String]
        attr_reader :table

        def initialize(table = nil, error_message = nil)
          if !error_message && table
            error_message = "表 #{table} で循環参照が起こりました"
          end

          super(error_message)

          @table = table
        end
      end
    end
  end
end
