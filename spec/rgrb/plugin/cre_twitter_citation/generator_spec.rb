# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/cre_twitter_citation/generator'

class RGRB::Plugin::CreTwitterCitation::Generator
  public :tweet_to_message
end

describe RGRB::Plugin::CreTwitterCitation::Generator do
  let(:generator) { described_class.new }

  describe '#tweet_to_message (private)' do
    shared_examples 'tweet_to_message' do |text|
      it(text) do
        expect(generator.tweet_to_message(tweet)).to eq(expected_message)
      end
    end

    context '通常のツイート' do
      let(:tweet) do
        File.open("#{__dir__}/tweet_normal.marshal") do |f|
          Marshal.load(f)
        end
      end

      let(:expected_message) do
        '【お知らせ】本日予定されておりましたメンテナンスは正常に終了しました。ご協力ありがとうございました。 (2014-09-01 23:50:28; https://twitter.com/cre_ne_jp/status/506454043175043072)'
      end

      include_examples 'tweet_to_message', 'テキスト、日時、ツイートの URL が含まれる'
    end

    context 'URL 入りのツイート' do
      let(:tweet) do
        File.open("#{__dir__}/tweet_url.marshal") do |f|
          Marshal.load(f)
        end
      end

      let(:expected_message) do
        '【お知らせ】一部サイトのメンテナンスについて、告知です。9月1日の夜、個人ブログやIRCログ公開などへのアクセスが一時的にできなくなります。 http://www.cre.ne.jp/2014/08/wordpress-maintenance-20140829.html (2014-08-29 22:21:49; https://twitter.com/cre_ne_jp/status/505344572990316545)'
      end

      include_examples 'tweet_to_message',  'URL が展開されたテキスト、日時、ツイートの URL が含まれる'
    end

    context 'HTML 実体参照入りのツイート' do
      let(:tweet) do
        File.open("#{__dir__}/tweet_html_entities.marshal") do |f|
          Marshal.load(f)
        end
      end

      let(:expected_message) do
        '【お知らせ】#あけましておめでとうございます 、2015年もクリエイターズネットワークをよろしくお願いいたします！　また、今年も新年あけおめ掲示板を開設しました。皆様の書き込みをお待ちしております。 <(_ _)> http://www.cre.ne.jp/2015/01/2015.html (2015-01-01 00:47:32; https://twitter.com/cre_ne_jp/status/550317340177338368)'
      end

      include_examples 'tweet_to_message', 'HTML 実体参照が実際の記号に変換される'
    end
  end
end
