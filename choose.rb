class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.3.1-custom-r1/choose-1.3.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "ab1bfb229b54b76b0bbf17af269ef20b4f9df556edcc1d8055cf62a82a673209"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/choose/releases/download/v1.3.1-custom-r1/choose-1.3.1-aarch64-apple-darwin.tar.xz"
      sha256 "1bd14f2b01d6d790ac74f770c7b49a38a941067f11f44d3a4dae8f03f534ba4b"
    else
      url "https://github.com/waltarix/choose/releases/download/v1.3.1-custom-r1/choose-1.3.1-x86_64-apple-darwin.tar.xz"
      sha256 "20c9c3a90324a12f39a5954fe5c704ed579096c8db7920d398ae48b9717b7111"
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
