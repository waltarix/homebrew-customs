class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.6.0-custom/dust-0.6.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "91c73d86f42a7d994e2579af0c230c6602291faef21bc634644e12a361a713e6"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.6.0-custom/dust-0.6.0-aarch64-apple-darwin.tar.xz"
      sha256 "d17c69354151cdafff3a290aac2c153a34277e0d65feca771878b4f2931cde30"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.6.0-custom/dust-0.6.0-x86_64-apple-darwin.tar.xz"
      sha256 "90a7128fd8e71557f780f618870d620d67309891b3720fa5718d3e1323eadaec"
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
