# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'rgrb/plugin/online_session_search/session'

describe RGRB::Plugin::OnlineSessionSearch::Session do
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

    describe '#id' do
      subject { session.id }
      it { should eq(id) }
    end

    describe '#url' do
      subject { session.url }
      it { should eq(url) }
    end

    describe '#name' do
      subject { session.name }
      it { should eq(name) }
    end

    describe '#game_system' do
      subject { session.game_system }
      it { should eq(game_system) }
    end

    describe '#start_time' do
      subject { session.start_time }
      it { should eq(start_time) }
    end

    describe '#min_members' do
      subject { session.min_members }
      it { should eq(min_members) }
    end

    describe '#max_members' do
      subject { session.max_members }
      it { should eq(max_members) }
    end

    describe '#account' do
      subject { session.account }
      it { should eq(account) }
    end

    describe '#user_name' do
      subject { session.user_name }
      it { should eq(user_name) }
    end

    describe '#twitter_image_url' do
      subject { session.twitter_image_url }
      it { should eq(twitter_image_url) }
    end

    describe '.parse_json' do
      subject { described_class.parse_json("[#{json}]").first }
      it 'JSON から正しく変換される' do
        expect(subject.id).to eq(id)
        expect(subject.url).to eq(url)
        expect(subject.name).to eq(name)
        expect(subject.game_system).to eq(game_system)
        expect(subject.min_members).to eq(min_members)
        expect(subject.max_members).to eq(max_members)
        expect(subject.account).to eq(account)
        expect(subject.user_name).to eq(user_name)
        expect(subject.twitter_image_url).to eq(twitter_image_url)
      end
    end
  end

  context 'セッション 1' do
    include_examples 'a session' do
      let(:id) { 9999 }
      let(:url) { 'http://session.trpg.net/9999' }
      let(:name) { 'セッション 1' }
      let(:game_system) { 'ソードワールド2.0' }
      let(:start_time) { Time.new(2015, 1, 23, 4, 56, 43, '+09:00') }
      let(:min_members) { 3 }
      let(:max_members) { 4 }
      let(:account) { '@foo' }
      let(:user_name) { 'Foo' }
      let(:twitter_image_url) { 'http://example.net/foo.png' }

      let(:json) do
        '{"SID":"9999","account":"@foo","username":"Foo","twitterimage":"http:\/\/example.net\/foo.png","SesName":"セッション 1","StartTime":"2015-01-23 04:56:43","MinMembers":"3","MaxMembers":"4","SysName":"ソードワールド2.0","url":"http:\/\/session.trpg.net\/9999"}'
      end
    end
  end

  context 'セッション 2' do
    include_examples 'a session' do
      let(:id) { 99999 }
      let(:url) { 'http://session.trpg.net/99999' }
      let(:name) { 'セッション 2' }
      let(:game_system) { 'エリュシオン' }
      let(:start_time) { Time.new(2015, 2, 10, 23, 59, 59, '+09:00') }
      let(:min_members) { 5 }
      let(:max_members) { 5 }
      let(:account) { '@bar' }
      let(:user_name) { 'Bar' }
      let(:twitter_image_url) { 'http://example.org/bar.png' }

      let(:json) do
        '{"SID":"99999","account":"@bar","username":"Bar","twitterimage":"http:\/\/example.org\/bar.png","SesName":"セッション 2","StartTime":"2015-02-10 23:59:59","MinMembers":"5","MaxMembers":"5","SysName":"エリュシオン","url":"http:\/\/session.trpg.net\/99999"}'
      end
    end
  end
end
