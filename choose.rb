class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.3.1-custom/choose-1.3.1-linux.tar.xz"
    sha256 "7d001996edbec89d21e9102c53f634d7b87b0a1b0c80588cc851d3560c19498e"
  else
    url "https://github.com/waltarix/choose/releases/download/v1.3.1-custom/choose-1.3.1-darwin.tar.xz"
    sha256 "60457a5ed109587a4eae4808dfab794abbce7ff581f6f5274172834bd5268f2e"
  end
  license "GPL-3.0"

  bottle :unneeded

  conflicts_with "choose-gui", because: "both install a `choose` binary"
  conflicts_with "choose-rust", because: "both install a `choose` binary"

  def install
    bin.install "choose"
  end

  test do
    input = "foo,  foobar,bar, baz"
    assert_equal "foobar bar", pipe_output("#{bin}/choose -f ',\\s*' 2:3", input).strip
  end
end
