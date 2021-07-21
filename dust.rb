class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.6.1-custom/dust-0.6.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "e8958b973dbbcf08969f4dce9e7d9c01b28d105f946a4ad0dc4d0cbb4a0f7c0e"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.6.1-custom/dust-0.6.1-aarch64-apple-darwin.tar.xz"
      sha256 "23fe7d484578e1973e00b135a513eac4716bd88beb913951555d09db2ead1c06"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.6.1-custom/dust-0.6.1-x86_64-apple-darwin.tar.xz"
      sha256 "bebb0ea36036af2d3398cf627f6db942cd81b2396fc2b77e6c96f7209ad095ac"
    end
  end
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
