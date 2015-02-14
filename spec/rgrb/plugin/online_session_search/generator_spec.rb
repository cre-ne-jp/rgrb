# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/online_session_search/generator'
require 'rgrb/plugin/online_session_search/session'

describe RGRB::Plugin::OnlineSessionSearch::Generator do
  let(:generator) { described_class.new }

  shared_examples 'a session' do
    let(:session) do
      described_class.new(
        id: id,
        url: url,
        name: name,
        game_system: game_system,
        start_time: start_time,
        min_members: min_members,
        max_members: max_members,
        account: account,
        user_name: user_name,
        twitter_image_url: twitter_image_url
      )
    end
  end

  describe '#format (private)' do
    shared_examples 'a session' do
      subject { generator.send(:format, [session]) }
      it { should eq([expected_message]) }
    end

    context 'セッション情報が見つからなかったとき' do
      let(:expected_message) { '開催予定のセッションは見つかりませんでしたの☆' }

      subject { generator.send(:format, []) }
      it { should eq([expected_message]) }
    end

    context 'セッション 1' do
      include_examples 'a session' do
        let(:session) do
          RGRB::Plugin::OnlineSessionSearch::Session.new(
            id: 9999,
            url: 'http://session.trpg.net/9999',
            name: 'セッション 1',
            game_system: 'ソードワールド2.0',
            start_time: Time.new(2015, 1, 23, 4, 56, 43, '+09:00'),
            min_members: 3,
            max_members: 4,
            account: '@foo',
            user_name: 'Foo',
            twitter_image_url: 'http://example.net/foo.png'
          )
        end
        let(:expected_message) do
          'ソードワールド2.0 / セッション 1 (2015-01-23 04:56; 3-4人; http://session.trpg.net/9999)'
        end
      end
    end

    context 'セッション 2' do
      include_examples 'a session' do
        let(:session) do
          RGRB::Plugin::OnlineSessionSearch::Session.new(
            id: 99999,
            url: 'http://session.trpg.net/99999',
            name: 'セッション 2',
            game_system: 'エリュシオン',
            start_time: Time.new(2015, 2, 10, 23, 59, 59, '+09:00'),
            min_members: 5,
            max_members: 5,
            account: '@bar',
            user_name: 'Bar',
            twitter_image_url: 'http://example.org/bar.png'
          )
        end
        let(:expected_message) do
          'エリュシオン / セッション 2 (2015-02-10 23:59; 5人; http://session.trpg.net/99999)'
        end
      end
    end
  end
end
