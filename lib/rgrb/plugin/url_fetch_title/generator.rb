# vim: fileencoding=utf-8

require 'socket'
require 'timeout'
require 'http'
require 'active_support'
require 'active_support/core_ext/numeric/conversions'
require 'guess_html_encoding'
require 'charlock_holmes'
require 'nokogiri'
require 'rgrb/version'
require 'rgrb/plugin_base/generator'

module RGRB
  module Plugin
    # ウェブページタイトル自動取得プラグイン
    module UrlFetchTitle
      # UrlFetchTitle の出力テキスト生成器。
      #
      # 実装は tiarra、mechanize を参考にしている。
      # 特徴は以下の通り。
      #
      # 1. MIME タイプによるファイルの種類の判別。
      # 2. http.rb を利用して HTML の先頭部分のみを読み込む。
      # 3. エンコーディングの自動判別。meta タグ、HTTP
      #    ヘッダを優先するが、無効な文字が現れないエンコーディングを選択する。
      #
      # @see https://bitbucket.org/mapi/tiarra/src/8c21fe9d660e4f4c85c408c95e3ab379d20c22aa/module/Auto/FetchTitle.pm?at=default&fileviewer=file-view-default Tiarra Auto::FetchTitle
      # @see https://github.com/sparklemotion/mechanize/blob/master/lib/mechanize/page.rb Mechanize::Page
      class Generator
        include PluginBase::Generator

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data プラグインの設定データ
        # @return [self]
        def configure(config_data)
          # 書き込みタイムアウト
          @write_timeout = config_data['WriteTimeout'] || 2
          # 接続タイムアウト
          @connect_timeout = config_data['ConnectTimeout'] || 5
          # 読み込みタイムアウト
          @read_timeout = config_data['ReadTimeout'] || 5
          # 最大リダイレクト回数
          @max_redirects = config_data['MaxRedirects'] || 10
          # 読み込みサイズ閾値（バイト単位）
          @read_size_threshold = config_data['ReadSizeThreshold'] || 65536
          # 返信の接頭辞
          @reply_prefix = config_data['ReplyPrefix'] || 'Fetch title: '
          # 返信の接尾辞
          @reply_suffix = config_data['ReplySuffix'] || ''
          # ユーザーエージェント
          user_agent_format = config_data['UserAgent'] ||
            "RGRB/%s (Creator's Network IRC bot)"
          @user_agent = user_agent_format % RGRB::VERSION

          self
        end

        # 誰かが発言した URL にアクセスし、ページの title タグを取得する
        #
        # @param [String] url タイトルを取得するページのURL
        # @return [String] 取得したタイトル、メタ情報
        def fetch_title(url)
          body =
            begin
              response = HTTP.
                timeout(write: @write_timeout,
                        connect: @connect_timeout,
                        read: @read_timeout).
                get(url,
                    headers: { 'User-Agent' => @user_agent },
                    follow: { max_hops: @max_redirects })
              status_code = response.code
              mime_type = response.mime_type
              is_html_file = %w(text/html application/xhtml+xml).
                include?(mime_type)

              case
              when status_code != 200
                reason = response.reason || '不明なエラー'
                "!! HTTP #{status_code} #{reason}"
              when is_html_file
                title = extract_title(response)
                title.empty? ? '(タイトルなし)' : title.gsub(/\s+/, ' ')
              else
                content_length = response.headers['Content-Length']
                parts = [
                  mime_type,
                  content_length && content_length.to_i.to_fs(:human_size)
                ].compact
                "(#{parts.join('; ')})"
              end
            rescue => e
              fetch_error_to_message(e)
            end

          "#{@reply_prefix}#{body}#{@reply_suffix}"
        end

        private

        # タイトル取得のエラーメッセージを返す
        # @param [StandardError] error エラーオブジェクト
        # @return [String]
        def fetch_error_to_message(error)
          body =
            case error
            when SocketError
              'サーバーに接続できませんでした'
            when Errno::ECONNREFUSED
              '接続が拒否されました'
            when HTTP::Redirector::TooManyRedirectsError,
              HTTP::Redirector::EndlessRedirectError
              "最大回数 (#{@max_redirects}) を超えてリダイレクトされました"
            when HTTP::TimeoutError, Timeout::Error, Errno::ETIMEDOUT, HTTP::ConnectionError
              'タイムアウト'
            else
              error.message
            end

          "!! #{body}"
        end

        # タイトルを抽出する
        # @param [HTTP::Response] response HTTP レスポンス
        # @return [String]
        def extract_title(response)
          content = read_head(response.body)
          encodings = detect_encodings(content, response.charset)

          doc = get_html_doc(content, encodings)
          return '' unless doc

          doc.
            search('title').
            inner_text.
            encode('UTF-8',
                   invalid: :replace,
                   undef: :replace,
                   replace: '?')
        end

        # 先頭部分を読み込む
        # @param [HTTP::Response::Body] body HTTP レスポンスの本体
        # @return [String]
        def read_head(body)
          # Frozen string literal でも困らないように String.new
          content = String.new
          read_size = 0

          while read_size < @read_size_threshold
            partial_content = body.readpartial
            break unless partial_content

            content << partial_content
            read_size += partial_content.bytesize
          end

          content
        end

        # エンコーディングを判別する
        # @return [Array<String>]
        def detect_encodings(html_code, response_header_charset)
          encodings = []

          begin
            html_encoding =
              GuessHtmlEncoding::HTMLScanner.new(html_code).encoding
            encodings << html_encoding if html_encoding
          rescue => guess_html_encoding_error
            logger.debug(
              "GuessHtmlEncoding error: #{guess_html_encoding_error}"
            )
          end

          encodings << response_header_charset if response_header_charset

          CharlockHolmes::EncodingDetector.
            detect_all(html_code).
            each do |info|
              encodings << info[:ruby_encoding]
            end

          encodings.empty? ? ['UTF-8'] : encodings.uniq
        end

        # エンコーディングが適切に設定された HTML ドキュメントを得る
        # @param [String] html_code HTML コード
        # @param [Array<String>] encodings エンコーディングを表す文字列の配列
        # @return [Nokogiri::HTML::Document]
        # @return [nil] 適切なエンコーディングが見つからなかった場合
        def get_html_doc(html_code, encodings)
          encodings.each do |encoding|
            begin
              doc = Nokogiri::HTML(html_code, nil, encoding)
              return doc unless encoding_error?(doc)
            rescue => e
              logger.debug("Nokogiri::HTML error: #{e}")
            end
          end

          nil
        end

        # エンコーディングエラーが起こったかどうかを返す
        # @param [Nokogiri::HTML::Document] doc HTML ドキュメント
        # @return [Boolean]
        def encoding_error?(doc)
          doc.errors.any? do |error|
            message = error.message
            message.include?('indicate encoding') ||
              message.include?('Invalid char') ||
              message.include?('input conversion failed')
          end
        end
      end
    end
  end
end
