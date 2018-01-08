# vim: fileencoding=utf-8

require_relative '../../../spec_helper'
require 'lumberjack'
require 'rgrb/plugin/server_connection_report/mail_sender'

describe RGRB::Plugin::ServerConnectionReport::MailSender do
  let(:test_data_dir) { File.expand_path('data', __dir__) }
  let(:test_data_file_path) {
    ->file_name { "#{test_data_dir}/#{file_name}" }
  }
  let(:mail_sender) {
    described_class.new({}, Lumberjack::Logger.new('/dev/null'))
  }

  describe '#initialize' do
    it 'インスタンスを初期化することができる' do
      expect(mail_sender).to be_truthy
    end

    it 'subject を正しく設定する' do
      expect(mail_sender.subject).to eq('')
    end

    it 'body を正しく設定する' do
      expect(mail_sender.body).to eq('')
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
