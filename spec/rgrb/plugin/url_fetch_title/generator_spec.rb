# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/version'
require 'rgrb/plugin/url_fetch_title/generator'

describe RGRB::Plugin::UrlFetchTitle::Generator do
  let(:generator) { described_class.new.configure({}) }
  let(:user_agent) do
    "RGRB/#{RGRB::VERSION} (Creator's Network IRC bot)"
  end

  describe '#configure (default)' do
    let(:write_timeout) { 2 }
    let(:connect_timeout) { 5 }
    let(:read_timeout) { 5 }
    let(:max_redirects) { 10 }
    let(:read_size_threshold) { 65536 }
    let(:reply_prefix) { 'Fetch title: ' }
    let(:reply_suffix) { '' }

    it '適切な既定値が設定される' do
      expect(generator.instance_variable_get(:@write_timeout)).
        to eq(write_timeout)
      expect(generator.instance_variable_get(:@connect_timeout)).
        to eq(connect_timeout)
      expect(generator.instance_variable_get(:@read_timeout)).
        to eq(read_timeout)
      expect(generator.instance_variable_get(:@max_redirects)).
        to eq(max_redirects)
      expect(generator.instance_variable_get(:@read_size_threshold)).
        to eq(read_size_threshold)
      expect(generator.instance_variable_get(:@reply_prefix)).
        to eq(reply_prefix)
      expect(generator.instance_variable_get(:@reply_suffix)).
        to eq(reply_suffix)
      expect(generator.instance_variable_get(:@user_agent)).
        to eq(user_agent)
    end
  end

  describe '#fetch_title' do
    let(:default_prefix) { 'Fetch title: ' }
    let(:default_suffix) { '[end]' }
    let(:format) do
      ->str { "#{default_prefix}#{str}#{default_suffix}" }
    end

    before do
      config = {
        :@no_ssl_verify => [],
        :@reply_prefix => default_prefix,
        :@reply_suffix => default_suffix
      }
      config.each do |var, value|
        generator.instance_variable_set(var, value)
      end
    end

    context 'HTML ファイル' do
      let(:url) { 'http://www.cre.ne.jp/' }
      let(:html_path) do
        File.expand_path('data/cre_ne_jp.html', File.dirname(__FILE__))
      end
      let(:body) { File.read(html_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => 'text/html; charset=UTF-8',
          }
        }
        stub_request(:head, url).to_return(response)
        stub_request(:get, url).
          to_return(response.merge(body: body))
      end

      subject { generator.fetch_title(url) }

      it '<title> タグの内容を含む' do
        expect(subject).to eq(format['クリエイターズネットワーク'])
      end

      it 'User-Agent が適切に設定されている' do
        generator.fetch_title(url)
        expect(WebMock).to have_requested(:get, url).
          with(headers: { 'User-Agent' => user_agent })
      end
    end

    context 'HTML ファイル (Shift_JIS)' do
      let(:url) { 'http://www.cre.ne.jp/' }
      let(:html_path) do
        File.expand_path('data/cre_ne_jp-shift_jis.html', File.dirname(__FILE__))
      end
      let(:body) { File.read(html_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => 'text/html',
          }
        }
        stub_request(:head, url).to_return(response)
        stub_request(:get, url).
          to_return(response.merge(body: body))
      end

      subject { generator.fetch_title(url) }
      it 'エンコーディングが適切に変換された <title> タグの内容を含む' do
        expect(subject).to eq(format['クリエイターズネットワーク'])
      end
    end

    context 'HTML ファイル (Shift_JIS; charset = UTF-8)' do
      let(:url) { 'http://www.cre.ne.jp/' }
      let(:html_path) do
        File.expand_path('data/cre_ne_jp-shift_jis-charset_utf_8.html', File.dirname(__FILE__))
      end
      let(:body) { File.read(html_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => 'text/html',
          }
        }
        stub_request(:head, url).to_return(response)
        stub_request(:get, url).
          to_return(response.merge(body: body))
      end

      subject { generator.fetch_title(url) }
      it 'エンコーディングが適切に変換された <title> タグの内容を含む' do
        expect(subject).to eq(format['クリエイターズネットワーク'])
      end
    end

    context 'HTML ファイル (Shift_JIS; content-type charset = UTF-8)' do
      let(:url) { 'http://www.cre.ne.jp/' }
      let(:html_path) do
        File.expand_path('data/cre_ne_jp-shift_jis-content_charset_utf_8.html', File.dirname(__FILE__))
      end
      let(:body) { File.read(html_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => 'text/html',
          }
        }
        stub_request(:head, url).to_return(response)
        stub_request(:get, url).
          to_return(response.merge(body: body))
      end

      subject { generator.fetch_title(url) }
      it 'エンコーディングが適切に変換された <title> タグの内容を含む' do
        expect(subject).to eq(format['クリエイターズネットワーク'])
      end
    end

    context 'HTML ファイル（リダイレクト）' do
      let(:status_codes) { [301, 302, 303, 307, 200] }
      let(:url) do
        {
          301 => 'http://www.cre.ne.jp/301',
          302 => 'http://www.cre.ne.jp/302',
          303 => 'http://www.cre.ne.jp/303',
          307 => 'http://www.cre.ne.jp/307',
          200 => 'http://www.cre.ne.jp/'
        }
      end

      let(:html_path) do
        File.expand_path('data/cre_ne_jp.html', File.dirname(__FILE__))
      end

      let(:body) { File.read(html_path) }

      before do
        response = {
          302 => {
            status: 302,
            headers: {
              'Location' => url[307]
            }
          },
          307 => {
            status: 307,
            headers: {
              'Location' => url[301]
            }
          },
          301 => {
            status: 301,
            headers: {
              'Location' => url[303]
            }
          },
          303 => {
            status: 303,
            headers: {
              'Location' => url[200]
            }
          },
          200 => {
            status: 200,
            headers: {
              'Content-Type' => 'text/html; charset=UTF-8',
            }
          }
        }

        status_codes.each do |status|
          stub_request(:head, url[status]).to_return(response[status])

          response_for_get =
            (status == 200) ? response[200].merge(body: body) : response[status]
          stub_request(:get, url[status]).to_return(response_for_get)
        end
      end

      context '最大リダイレクト回数に到達した場合' do
        let(:max_redirects) { 3 }
        before do
          generator.instance_variable_set(:@max_redirects, max_redirects)
        end

        subject { generator.fetch_title(url[302]) }
        it '最大リダイレクト回数を超えたことを示すエラーメッセージが返る' do
          expect(subject).to eq(format["!! 最大回数 (#{max_redirects}) を超えてリダイレクトされました"])
        end
      end
    end

    context 'HTML ファイル（タイトルなし）' do
      let(:url) { 'http://example.net/empty_title' }
      let(:html_path) do
        File.expand_path('data/empty_title.html', File.dirname(__FILE__))
      end
      let(:body) { File.read(html_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => 'text/html; charset=UTF-8',
          }
        }
        stub_request(:head, url).to_return(response)
        stub_request(:get, url).
          to_return(response.merge(body: body))
      end

      subject { generator.fetch_title(url) }
      it 'タイトルがないことを示すメッセージが返る' do
        expect(subject).to eq(format['(タイトルなし)'])
      end
    end

    context '画像ファイル' do
      let(:url) { 'https://www.cre.ne.jp/wp-content/themes/wsc7/img/cre_banner.jpg' }
      let('content_type') { 'image/jpeg' }
      let(:image_path) do
        File.expand_path('data/cre_banner.jpg', File.dirname(__FILE__))
      end
      let(:body) { File.binread(image_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => content_type,
            'Content-Length' => 4297
          }
        }
        stub_request(:get, url).to_return(response)
      end

      subject { generator.fetch_title(url) }
      it 'Content-Type と読みやすい Content-Length を含む' do
        expect(subject).to eq(format["(#{content_type}; 4.2 KB)"])
      end
    end

    context 'プレーンテキスト' do
      let(:url) { 'http://example.net/example.txt' }
      let(:content_type) { 'text/plain' }
      let(:content) { 'あいうえお test' }

      before do
        response = {
          body: content,
          status: 200,
          headers: {
            'Content-Type' => content_type,
            'Content-Length' => 20
          }
        }
        stub_request(:get, url).to_return(response)
      end

      subject { generator.fetch_title(url) }
      it 'Content-Type と読みやすい Content-Length を含む' do
        expect(subject).to eq(format["(#{content_type}; 20 Bytes)"])
      end
    end

    context 'サーバーに接続できない場合' do
      let(:url) { 'http://invaliddomain.net' }

      before do
        stub_request(:get, url).to_raise(SocketError)
      end

      subject { generator.fetch_title(url) }
      it 'サーバーに接続できないことを示すエラーメッセージが返る' do
        expect(subject).to eq(format['!! サーバーに接続できませんでした'])
      end
    end

    context '接続が拒否された場合' do
      let(:url) { 'http://refuse.net' }

      before do
        stub_request(:get, url).to_raise(Errno::ECONNREFUSED)
      end

      subject { generator.fetch_title(url) }
      it '接続が拒否されたことを示すエラーメッセージが返る' do
        expect(subject).to eq(format['!! 接続が拒否されました'])
      end
    end

    context 'タイムアウトした場合' do
      let(:timeout_url) { 'http://example.net/timeout' }
      let(:open_timeout_url) { 'http://example.net/open_timeout' }
      let(:read_timeout_url) { 'http://example.net/read_timeout' }
      let(:error_message) { '!! タイムアウト' }

      before do
        stub_request(:get, timeout_url).to_timeout
        stub_request(:get, open_timeout_url).to_raise(Net::OpenTimeout)
        stub_request(:get, read_timeout_url).to_raise(Net::ReadTimeout)
      end

      it 'タイムアウトしたことを示すエラーメッセージが返る' do
        expect(generator.fetch_title(timeout_url)).
          to eq(format[error_message])
        expect(generator.fetch_title(open_timeout_url)).
          to eq(format[error_message])
        expect(generator.fetch_title(read_timeout_url)).
          to eq(format[error_message])
      end
    end

    context '401 Unauthorized' do
      let(:url) { 'http://example.net/need_login' }

      before do
        stub_request(:get, url).to_return(status: 401)
      end

      subject { generator.fetch_title(url) }
      it '"401 Unauthorized" エラーメッセージが返る' do
        expect(subject).to eq(format['!! HTTP 401 Unauthorized'])
      end
    end

    context '403 Forbidden' do
      let(:url) { 'http://example.net/secret' }

      before do
        stub_request(:get, url).to_return(status: 403)
      end

      subject { generator.fetch_title(url) }
      it '"403 Forbidden" エラーメッセージが返る' do
        expect(subject).to eq(format['!! HTTP 403 Forbidden'])
      end
    end

    context '404 Not Found' do
      let(:url) { 'http://example.net/not_found' }

      before do
        stub_request(:get, url).to_return(status: 404)
      end

      subject { generator.fetch_title(url) }
      it '"404 Not Found" エラーメッセージが返る' do
        expect(subject).to eq(format['!! HTTP 404 Not Found'])
      end
    end

    context '不明な HTTP エラー' do
      let(:url) { 'http://example.net/strange_error' }

      before do
        stub_request(:get, url).to_return(status: 999)
      end

      subject { generator.fetch_title(url) }
      it '"不明なエラー" エラーメッセージが返る' do
        expect(subject).to eq(format['!! HTTP 999 不明なエラー'])
      end
    end
  end
end
