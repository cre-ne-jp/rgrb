# vim: fileencoding=utf-8

require_relative '../../../spec_helper'

require 'yaml'
require 'lumberjack'
require 'rgrb/plugin/server_connection_report/mail_generator'

describe RGRB::Plugin::ServerConnectionReport::MailGenerator do
  let(:test_data_dir) { File.expand_path('data', __dir__) }
  let(:test_data_file_path) {
    ->file_name { "#{test_data_dir}/#{file_name}" }
  }

  let(:template_cre_path) { test_data_file_path['cre.txt'] }

  let(:null_logger) { Lumberjack::Logger.new('/dev/null') }

  let(:config_data) {
    {
      'Mail' => {
        'To' => ['admin@example.net'],
        'SMTP' => {
          'address' => 'localhost',
          'port' => 25,
          'domain' => 'smtp.example.net',
          'authentication' => false,
          'ssl' => false,
          'enable_starttls_auto' => false
        }
      }
    }
  }

  let(:mail_generator) {
    g = described_class.new
    g.logger = Lumberjack::Logger.new($stdout, progname: self.class.to_s)

    g
  }

  describe '#initialize' do
    it 'インスタンスを初期化することができる' do
      expect(mail_generator).to be_truthy
    end

    it 'subject を正しく設定する' do
      expect(mail_generator.subject).to eq('')
    end

    it 'body を正しく設定する' do
      expect(mail_generator.body).to eq('')
    end

    it 'irc_host を正しく設定する' do
      expect(mail_generator.irc_host).to eq('')
    end

    it 'irc_nick を正しく設定する' do
      expect(mail_generator.irc_nick).to eq('')
    end

    it 'irc_network を正しく設定する' do
      expect(mail_generator.irc_network).to eq('')
    end

    it 'to を正しく設定する' do
      expect(mail_generator.to).to eq('root@localhost')
    end
  end

  describe '#configure' do
    let(:configured_mail_generator) {
      mail_generator.configure(config_data)
    }

    describe '@to' do
      context '指定されていなかった場合' do
        it 'to が設定されない' do
          config_data['Mail']['To'] = nil
          expect(configured_mail_generator.to).to eq('root@localhost')
        end
      end

      context '指定されていた場合' do
        it 'to を設定する' do
          expect(configured_mail_generator.to).to eq(['admin@example.net'])
        end
      end
    end

    describe '@mail_config' do
      let(:expected_symbol_keys) {
        {
          address: 'localhost',
          port: 25,
          domain: 'smtp.example.net',
          authentication: false,
          ssl: false,
          enable_starttls_auto: false
        }
      }

      let(:smtp_config_with_nil_value) {
        YAML.load(<<-YAML)
        authentication: false
        # YAMLではnilではなくnull
        invalid_key: null
        YAML
      }

      let(:expected_rejected_nil_value) {
        {
          authentication: false
        }
      }

      it 'キーを文字列からシンボルに変換する' do
        expect(configured_mail_generator.instance_variable_get(:@mail_config)).
          to eq(expected_symbol_keys)
      end

      it 'nullの項目を除く' do
        config_data['Mail']['SMTP'] = smtp_config_with_nil_value
        expect(configured_mail_generator.instance_variable_get(:@mail_config)).
          to eq(expected_rejected_nil_value)
      end
    end
  end

  describe 'メールテンプレート読み込み' do
    let(:empty_file_path) { test_data_file_path['empty.txt'] }
    let(:only_subject_file_path) { test_data_file_path['only_subject.txt'] }

    let(:cre_subject) { 'IRC サーバ%{status2}通知 (%{server})' }
    let(:cre_body) { %Q("%{server}" がネットワーク%{status1}ました。\n) }

    describe '#load_mail_template' do
      context '空のファイル' do
        let(:content) { File.read(empty_file_path) }

        it '読み込みに失敗する' do
          expect(content.length).to eq(0)
          expect { mail_generator.load_mail_template(content) }.
            to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context '件名のみ' do
        let(:content) { File.read(only_subject_file_path) }

        it '読み込みに失敗する' do
          expect(content.lines.length).to eq(2)
          expect { mail_generator.load_mail_template(content) }.
            to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context 'cre' do
        let(:content) { File.read(template_cre_path) }

        it 'self を返す' do
          expect(content.lines.length).to be > 2
          expect(mail_generator.load_mail_template(content)).to be(mail_generator)
        end

        it '件名を正しく設定する' do
          expect(content.lines.length).to be > 2

          mail_generator.load_mail_template(content)
          expect(mail_generator.subject).to eq(cre_subject)
        end

        it '本文を正しく設定する' do
          expect(content.lines.length).to be > 2

          mail_generator.load_mail_template(content)
          expect(mail_generator.body).to eq(cre_body)
        end
      end
    end

    describe '#load_mail_template_file' do
      context '空のファイル' do
        it '読み込みに失敗する' do
          expect {
            mail_generator.load_mail_template_file(empty_file_path)
          }.to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context '件名のみ' do
        it '読み込みに失敗する' do
          expect {
            mail_generator.load_mail_template_file(only_subject_file_path)
          }.to raise_error(described_class::MailTemplateLoadError)
        end
      end

      context 'cre' do
        let(:cre_mail_generator) {
          mail_generator.load_mail_template_file(template_cre_path)
        }

        it 'self を返す' do
          expect(cre_mail_generator).to be(mail_generator)
        end

        it '件名を正しく設定する' do
          expect(cre_mail_generator.subject).to eq(cre_subject)
        end

        it '本文を正しく設定する' do
          expect(cre_mail_generator.body).to eq(cre_body)
        end
      end
    end

    describe '#load_mail_template_by_name' do
      context 'cre' do
        let(:cre_mail_generator) {
          mail_generator.data_path = test_data_dir
          mail_generator.load_mail_template_by_name('cre')
        }

        it 'self を返す' do
          expect(cre_mail_generator).to be(mail_generator)
        end

        it '件名を正しく設定する' do
          expect(cre_mail_generator.subject).to eq(cre_subject)
        end

        it '本文を正しく設定する' do
          expect(cre_mail_generator.body).to eq(cre_body)
        end
      end
    end
  end

  describe '#generate' do
    let(:cre_mail_generator) {
      mail_generator.load_mail_template_file(template_cre_path)
      mail_generator.irc_host = 'irc.cre.jp'
      mail_generator.irc_nick = 'RGRB'
      mail_generator.irc_network = "Creator'sNetworkIRC"

      mail_generator
    }

    let(:mail_data_joined) {
      cre_mail_generator.generate(
        'irc.kazagakure.net',
        :joined,
        Time.new(2018, 1, 23, 4, 56, 12, '+09:00'),
        'ネットワークへの参加'
      )
    }

    let(:mail_data_disconnected) {
      cre_mail_generator.generate(
        'irc.kazagakure.net',
        :disconnected,
        Time.new(2018, 1, 23, 4, 56, 12, '+09:00'),
        'ネットワークからの切断'
      )
    }

    it 'deliver メソッドが存在する' do
      expect(mail_data_joined.respond_to?(:deliver)).to be(true)
    end

    it 'from を正しく設定する' do
      expect(mail_data_joined.from[0]).to eq('rgrb-RGRB@irc.cre.jp')
      expect(mail_data_joined['from'].display_names[0]).
        to eq("RGRB on Creator'sNetworkIRC")
    end

    context 'ネットワークへの参加' do
      it 'subject を正しく設定する' do
        expect(mail_data_joined.subject).to eq(
          'IRC サーバ接続通知 (irc.kazagakure.net)'
        )
      end

      it 'body を正しく設定する' do
        expect(mail_data_joined.body.raw_source).to eq(
          %Q("irc.kazagakure.net" がネットワークに参加しました。\r\n)
        )
      end
    end

    context 'ネットワークからの切断' do
      it 'subject を正しく設定する' do
        expect(mail_data_disconnected.subject).to eq(
          'IRC サーバ切断通知 (irc.kazagakure.net)'
        )
      end

      it 'body を正しく設定する' do
        expect(mail_data_disconnected.body.raw_source).to eq(
          %Q("irc.kazagakure.net" がネットワークから切断されました。\r\n)
        )
      end
    end

    describe 'パーツの置換' do
      it 'time を正しく置換する' do
        cre_mail_generator.body = '%{time}'
        expect(mail_data_joined.body).to eq('2018年01月23日 04:56:12')
      end

      it 'server を正しく置換する' do
        cre_mail_generator.body = '%{server}'
        expect(mail_data_joined.body).to eq('irc.kazagakure.net')
      end

      it 'message を正しく置換する' do
        cre_mail_generator.body = '%{message}'
        expect(mail_data_joined.body).to eq('ネットワークへの参加')
      end

      it 'rgrb_version を正しく置換する' do
        cre_mail_generator.body = '%{rgrb_version}'
        expect(mail_data_joined.body).to eq(RGRB::VERSION)
      end
    end
  end
end
