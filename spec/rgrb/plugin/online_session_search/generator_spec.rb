# vim: fileencoding=utf-8

require 'open-uri'
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

  describe '#session_data_from (private)' do
    context 'HTTP エラーが起きたとき' do
      let(:url) { 'http://session.trpg.net/json.php?n=5' }

      before do
        stub_request(:get, url).to_raise(StandardError)
      end

      it do
        expect { generator.send(:session_data_from, url) }.
          to raise_error(StandardError)
      end
    end

    context 'セッション情報が見つからなかったとき' do
      let(:url) { 'http://session.trpg.net/json.php?n=5' }

      before do
        stub_request(:get, url).to_return(body: '[]')
      end

      subject { generator.send(:session_data_from, url) }
      it { should eq(['開催予定のセッションは見つかりませんでしたの☆']) }
    end

    context 'セッション 1, 2' do
      let(:url) { 'http://session.trpg.net/json.php?n=2' }
      let(:session_1_2_json) do
        '[{"SID":"9999","account":"@foo","username":"Foo","twitterimage":"http:\/\/example.net\/foo.png","SesName":"セッション 1","StartTime":"2015-01-23 04:56:43","MinMembers":"3","MaxMembers":"4","SysName":"ソードワールド2.0","url":"http:\/\/session.trpg.net\/9999"},{"SID":"99999","account":"@bar","username":"Bar","twitterimage":"http:\/\/example.org\/bar.png","SesName":"セッション 2","StartTime":"2015-02-10 23:59:59","MinMembers":"5","MaxMembers":"5","SysName":"エリュシオン","url":"http:\/\/session.trpg.net\/99999"}]'
      end

      before do
        stub_request(:get, url).to_return(body: session_1_2_json)
      end

      subject { generator.send(:session_data_from, url) }
      it do
        should eq([
          'ソードワールド2.0 / セッション 1 (2015-01-23 04:56; 3-4人; http://session.trpg.net/9999)',
          'エリュシオン / セッション 2 (2015-02-10 23:59; 5人; http://session.trpg.net/99999)'
        ])
      end
    end
  end

  describe '#latest_schedules' do
    shared_examples 'latest_schedules' do |num|
      context "n = #{num}" do
        let(:url) { "http://session.trpg.net/json.php?n=#{num}" }

        before do
          stub_request(:get, url).to_return(body: '[]')
        end

        it '正しい URL に対して GET を送る' do
          generator.latest_schedules(num)
          expect(WebMock).to have_requested(:get, url).once
        end
      end
    end

    include_examples 'latest_schedules', 5
    include_examples 'latest_schedules', 10
  end

  describe '#search' do
    shared_examples 'search' do
      before do
        stub_request(:get, url).to_return(body: '[]')
      end

      it '正しい URL に対して GET を送る' do
        generator.search(str, num)
        expect(WebMock).to have_requested(:get, url).once
      end
    end

    context 'ソードワールド (n = 5)' do
      include_examples 'search' do
        let(:str) { 'ソードワールド' }
        let(:num) { 5 }
        let(:url) { 'http://session.trpg.net/json.php?s=%E3%82%BD%E3%83%BC%E3%83%89%E3%83%AF%E3%83%BC%E3%83%AB%E3%83%89&n=5' }
      end
    end

    context 'エリュシオン (n = 10)' do
      include_examples 'search' do
        let(:str) { 'エリュシオン' }
        let(:num) { 10 }
        let(:url) { 'http://session.trpg.net/json.php?s=%E3%82%A8%E3%83%AA%E3%83%A5%E3%82%B7%E3%82%AA%E3%83%B3&n=10' }
      end
    end
  end
end
