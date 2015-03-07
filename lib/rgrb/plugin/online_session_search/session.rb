# vim: fileencoding=utf-8

require 'json'
require 'time'

module RGRB
  module Plugin
    module OnlineSessionSearch
      # オンラインセッション情報を格納するクラス
      class Session
        # ID
        # @return [Integer]
        attr_reader :id
        # セッション情報の URL
        # @return [String]
        attr_reader :url
        # セッション名
        # @return [String]
        attr_reader :name
        # ゲームシステム名
        # @return [String]
        attr_reader :game_system
        # 開始日時
        # @return [Time]
        attr_reader :start_time
        # 最低人数
        # @return [Integer]
        attr_reader :min_members
        # 最高人数
        # @return [Integer]
        attr_reader :max_members
        # アカウント
        # @return [String]
        attr_reader :account
        # ユーザー名
        # @return [String]
        attr_reader :user_name
        # Twitter 画像 URL
        # @return [String]
        attr_reader :twitter_image_url

        # JSON からセッション情報へ変換する
        #
        # 入力される JSON はセッション情報の配列と仮定している
        #
        # @return [Array<OnlineSessionSearch::Session>]
        def self.parse_json(json)
          sessions = JSON.parse(json)
          sessions.map do |data|
            new(
              id: data['SID'].to_i,
              url: data['url'],
              name: data['SesName'],
              game_system: data['SysName'],
              start_time: Time.parse("#{data['StartTime']} +0900"),
              min_members: data['MinMembers'].to_i,
              max_members: data['MaxMembers'].to_i,
              account: data['account'],
              user_name: data['username'],
              twitter_image_url: data['twitterimage']
            )
          end
        end

        # 新しい Session インスタンスを返す
        # @param [Hash] session_data セッション情報
        # @option session_data [Integer] :id ID
        # @option session_data [String] :url セッション情報の URL
        # @option session_data [String] :name セッション名
        # @option session_data [String] :game_system ゲームシステム名
        # @option session_data [Time] :start_time 開始日時
        # @option session_data [Integer] :min_members 最低人数
        # @option session_data [Integer] 最高人数
        # @option session_data [String] アカウント
        # @option session_data [String] ユーザー名
        # @option session_data [String] Twitter 画像 URL
        def initialize(session_data)
          default_session_data = {
            id: 0,
            url: '',
            name: '',
            game_system: '',
            start_time: Time.now,
            min_members: 0,
            max_members: 1,
            account: '',
            user_name: '',
            twitter_image_url: ''
          }
          actual_session_data = default_session_data.merge(session_data)

          @id = actual_session_data[:id]
          @url = actual_session_data[:url]
          @name = actual_session_data[:name]
          @game_system = actual_session_data[:game_system]
          @start_time = actual_session_data[:start_time]
          @min_members = actual_session_data[:min_members]
          @max_members = actual_session_data[:max_members]
          @account = actual_session_data[:account]
          @user_name = actual_session_data[:user_name]
          @twitter_image_url = actual_session_data[:twitter_image_url]
        end
      end
    end
  end
end
