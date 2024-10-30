# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module ServerConnectionReport
      # ホスト名を表す正規表現
      #
      # @see https://stackoverflow.com/questions/106179/regular-expression-to-match-dns-hostname-or-ip-address
      HOSTNAME_RE =
        /(?:[a-z\d](?:[-a-z\d]{0,61}[a-z\d])?
          (?:\.[a-z\d](?:[-a-z\d]{0,61}[a-z\d])?)*)/ix
    end
  end
end
