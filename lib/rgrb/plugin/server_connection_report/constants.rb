# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module ServerConnectionReport
      # ホスト名を表す正規表現
      HOSTNAME_RE =
        /(?:[a-z\d](?:[-a-z\d]{0,61}[a-z\d])?
          (?:\.[a-z\d](?:[-a-z\d]{0,61}[a-z\d])?)*)/ix
    end
  end
end
