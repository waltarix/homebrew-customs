class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.3.4-custom/choose-1.3.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "43a38d0e2fae46ccf38fc689d34d2395192da74ea1be993befa65e1750206d05"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/choose/releases/download/v1.3.4-custom/choose-1.3.4-aarch64-apple-darwin.tar.xz"
      sha256 "1a783888d95a3fd822b3d23412de346bde3493bc345e33838c46b18993d345b4"
    else
      url "https://github.com/waltarix/choose/releases/download/v1.3.4-custom/choose-1.3.4-x86_64-apple-darwin.tar.xz"
      sha256 "912456ea7f8199cce0da99f786aece76260c14b78ff3b59ba5b74c448a1bae1b"
    end
  end
  license "GPL-3.0-or-later"

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
