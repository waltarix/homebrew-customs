class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.3.3-custom/choose-1.3.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "0a19855a57f0e0544061de09072378a7bab680e8255b08faa2ee6796a18f6b97"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/choose/releases/download/v1.3.3-custom/choose-1.3.3-aarch64-apple-darwin.tar.xz"
      sha256 "085fc1d7ab0f664f3ad0e243121df22f49b7cbe16fc1651ac56099a78f674555"
    else
      url "https://github.com/waltarix/choose/releases/download/v1.3.3-custom/choose-1.3.3-x86_64-apple-darwin.tar.xz"
      sha256 "d23684a2132f2e71b1b0916f3ef20178d7995a013b359d58cf144f4a409d3492"
    end
  end
  license "GPL-3.0-or-later"

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
