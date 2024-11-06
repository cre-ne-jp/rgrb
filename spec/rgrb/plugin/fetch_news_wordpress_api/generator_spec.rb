# vim: fileencoding=utf-8

require 'json'
require_relative '../../../spec_helper'
require 'rgrb/plugin/fetch_news_wordpress_api/generator'

class RGRB::Plugin::FetchNewsWordpressApi::Generator
  public :post_to_message
end

describe RGRB::Plugin::FetchNewsWordpressApi::Generator do
  let(:generator) { described_class.new.configure({}) }

  describe '#post_to_message (private)' do
    shared_examples 'cat' do |id|
      let(:url) { "https://www.cre.ne.jp/wp-json/wp/v2/categories/#{id}" }
      let(:json_path) do
        File.expand_path("category_#{id}.json", File.dirname(__FILE__))
      end
      let(:body) { File.read(json_path) }

      before do
        response = {
          status: 200,
          headers: {
            'Content-Type' => 'application/json; charset=UTF-8',
          }
        }
        stub_request(:head, url).to_return(response)
        stub_request(:get, url).
          to_return(response.merge(body: body))
      end

      subject { generator.post_to_message(post) }
      it { should eq(expected_message) }
    end

    let(:posts) do
      JSON.parse(File.read(
        File.expand_path('posts.json', File.dirname(__FILE__))
      ))
    end

    context 'カテゴリ: お知らせ' do
      include_examples 'cat', 1 do
        let(:post) { posts[0] }
        let(:expected_message) { '【お知らせ】IRCサーバ “irc.sougetu.net” 提供終了のお知らせ (2024-05-02 19:00:00; https://www.cre.ne.jp/2024/05/irc-sougetu-server-end-html.html)' }
      end
    end

    context 'カテゴリ: 障害情報' do
      include_examples 'cat', 17 do
        let(:post) { posts[9] }
        let(:expected_message) { '【障害情報】【メンテナンス予告あり】風隠IRCのネットワーク障害について (2015-09-18 23:12:37; https://www.cre.ne.jp/2015/09/kazagakure-netwark-fall-20150918.html)' }
      end
    end

    context 'カテゴリ: 今後のメンテナンス' do
      include_examples 'cat', 55 do
        let(:post) { posts[1] }
        let(:expected_message) { '【今後のメンテナンス】【語り部総本部】IRCログ公開システム変更のお知らせ (2021-02-15 21:45:15; https://www.cre.ne.jp/2021/02/irclog-webaccess-kataribe.html)' }
      end
    end
  end
end
