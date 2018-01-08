# vim: fileencoding=utf-8

require_relative '../../../spec_helper'

require 'yaml'
require 'lumberjack'
require 'rgrb/plugin/server_connection_report/mail_sender'

describe RGRB::Plugin::ServerConnectionReport::MailSender do
  let(:test_data_dir) { File.expand_path('data', __dir__) }
  let(:test_data_file_path) {
    ->file_name { "#{test_data_dir}/#{file_name}" }
  }

  let(:null_logger) { Lumberjack::Logger.new('/dev/null') }
  let(:mail_sender) { described_class.new({}, null_logger) }

  describe '#initialize' do
    it 'インスタンスを初期化することができる' do
      expect(mail_sender).to be_truthy
    end

    it 'to を正しい既定値に設定する' do
      expect(mail_sender.to).to eq('root@localhost')
    end

    it 'subject を正しく設定する' do
      expect(mail_sender.subject).to eq('')
    end

    it 'body を正しく設定する' do
      expect(mail_sender.body).to eq('')
    end

    it 'irc_host を正しく設定する' do
      expect(mail_sender.irc_host).to eq('')
    end

    it 'irc_nick を正しく設定する' do
      expect(mail_sender.irc_nick).to eq('')
    end

    it 'irc_network を正しく設定する' do
      expect(mail_sender.irc_network).to eq('')
    end

    describe '@mail_config' do
      let(:mail_config_hash_1) {
        YAML.load(<<-YAML)
        SMTP:
          address: localhost
          port: 25
        YAML
      }

      let(:expected_1) {
        {
          address: 'localhost',
          port: 25
        }
      }

      let(:mail_config_hash_2) {
        YAML.load(<<-YAML)
        SMTP:
          authentication: false
          # YAMLではnilではなくnull
          invalid_key: null
        YAML
      }

      let(:expected_2) {
        {
          authentication: false
        }
      }

      it 'キーを文字列からシンボルに変換する' do
        mail_sender_2 = described_class.new(mail_config_hash_1, null_logger)
        expect(mail_sender_2.instance_variable_get(:@mail_config)).
          to eq(expected_1)
      end

      it 'nullの項目を除く' do
        mail_sender_2 = described_class.new(mail_config_hash_2, null_logger)
        expect(mail_sender_2.instance_variable_get(:@mail_config)).
          to eq(expected_2)
      end
    end
  end

  describe 'メールテンプレート読み込み' do
    let(:empty_file_path) { test_data_file_path['empty.txt'] }
    let(:only_subject_file_path) { test_data_file_path['only_subject.txt'] }
    let(:template_cre_path) { test_data_file_path['cre.txt'] }

    let(:cre_subject) { 'IRC サーバ%{status2}通知 (%{server})' }
    let(:cre_body) { %Q("%{server}" がネットワーク%{status1}ました。\n) }

    describe '#load_mail_template' do
      context '空のファイル' do
        let(:content) { File.read(empty_file_path) }

        it '読み込みに失敗する' do
          expect(content.length).to eq(0)
          expect { mail_sender.load_mail_template(content) }.
            to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context '件名のみ' do
        let(:content) { File.read(only_subject_file_path) }

        it '読み込みに失敗する' do
          expect(content.lines.length).to eq(2)
          expect { mail_sender.load_mail_template(content) }.
            to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context 'cre' do
        let(:content) { File.read(template_cre_path) }

        it 'self を返す' do
          expect(content.lines.length).to be > 2
          expect(mail_sender.load_mail_template(content)).to be(mail_sender)
        end

        it '件名を正しく設定する' do
          expect(content.lines.length).to be > 2

          mail_sender.load_mail_template(content)
          expect(mail_sender.subject).to eq(cre_subject)
        end

        it '本文を正しく設定する' do
          expect(content.lines.length).to be > 2

          mail_sender.load_mail_template(content)
          expect(mail_sender.body).to eq(cre_body)
        end
      end
    end

    describe '#load_mail_template_file' do
      context '空のファイル' do
        it '読み込みに失敗する' do
          expect {
            mail_sender.load_mail_template_file(empty_file_path)
          }.to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context '件名のみ' do
        it '読み込みに失敗する' do
          expect {
            mail_sender.load_mail_template_file(only_subject_file_path)
          }.to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context 'cre' do
        it 'self を返す' do
          expect(mail_sender.load_mail_template_file(template_cre_path)).
            to be(mail_sender)
        end

        it '件名を正しく設定する' do
          mail_sender.load_mail_template_file(template_cre_path)
          expect(mail_sender.subject).to eq(cre_subject)
        end

        it '本文を正しく設定する' do
          mail_sender.load_mail_template_file(template_cre_path)
          expect(mail_sender.body).to eq(cre_body)
        end
      end
    end
  end
end
