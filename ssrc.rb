require "formula"

class Ssrc < Formula
  homepage "http://shibatch.sourceforge.net"
  url "http://shibatch.sourceforge.net/download/ssrc-1.30.tgz"
  sha256 "088286a2806153c3360a84c160540405b4d07fa6af5991cde4d84e8566ee1faa"

  def install
    system "make"
    bin.install %w[ssrc ssrc_hp]
  end
end
