# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/cre_twitter_citation/generator'

class RGRB::Plugin::CreTwitterCitation::Generator
  public :tweet_to_message
end

describe RGRB::Plugin::CreTwitterCitation::Generator do
  let(:generator) { described_class.new }
  let(:tweet_normal) do
    File.open("#{__dir__}/tweet_normal.marshal") do |f|
      Marshal.load(f)
    end
  end
  let(:tweet_url) do
    File.open("#{__dir__}/tweet_url.marshal") do |f|
      Marshal.load(f)
    end
  end

  describe '#tweet_to_message (private)' do
    context '通常のツイート' do
      let(:expected_message) do
        '【お知らせ】本日予定されておりましたメンテナンスは正常に終了しました。ご協力ありがとうございました。 (2014-09-01 23:50:28; https://twitter.com/cre_ne_jp/status/506454043175043072)'
      end

      it 'テキスト、日時、ツイートの URL が含まれる' do
        expect(generator.tweet_to_message(tweet_normal)).
          to eq(expected_message)
      end
    end

    context 'URL 入りのツイート' do
      let(:expected_message) do
        '【お知らせ】一部サイトのメンテナンスについて、告知です。9月1日の夜、個人ブログやIRCログ公開などへのアクセスが一時的にできなくなります。 http://www.cre.ne.jp/2014/08/wordpress-maintenance-20140829.html (2014-08-29 22:21:49; https://twitter.com/cre_ne_jp/status/505344572990316545)'
      end

      it 'URL が展開されたテキスト、日時、ツイートの URL が含まれる' do
        expect(generator.tweet_to_message(tweet_url)).
          to eq(expected_message)
      end
    end
  end
end
