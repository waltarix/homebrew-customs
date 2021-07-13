class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.3.2-custom/choose-1.3.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "daa18d6134ada6697a204081e98d89a1cc1910c16f4b2e7113f9b62ee8ae16d7"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/choose/releases/download/v1.3.2-custom/choose-1.3.2-aarch64-apple-darwin.tar.xz"
      sha256 "0b895597caa24636080f40839359a2e9e72105e6dd60fda333f955fa40e915db"
    else
      url "https://github.com/waltarix/choose/releases/download/v1.3.2-custom/choose-1.3.2-x86_64-apple-darwin.tar.xz"
      sha256 "3cd2bda969f8331847be52df81c834373dfd6546563459e885e13f439287efe1"
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
