class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.4-custom-r1/dust-0.5.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "b7fb11b9bcc8ac03d08277ab93f206aac006affaf91b71d77f0b7d6d8b00b494"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.5.4-custom-r1/dust-0.5.4-aarch64-apple-darwin.tar.xz"
      sha256 "c4486e1c3caab5e8e2ea8d3647b97dd22aa308b0e2837756c8010d438ab539f6"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.5.4-custom-r1/dust-0.5.4-x86_64-apple-darwin.tar.xz"
      sha256 "7ac513ef6a3e6b1a3c515b7005869e0a17e6e62a3557d3c5e568a58a3d58fd94"
    end
  end
  license "Apache-2.0"
  head "https://github.com/bootandy/dust.git"

  livecheck do
    url :head
    regex(/v([\d.]+)/i)
  end

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
