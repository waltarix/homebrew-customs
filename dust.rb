class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.6.2-custom/dust-0.6.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "75c431694707eb6f1fa914acdc0eef40408413ff367ff5dffeb90fc6774b3f3c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.6.2-custom/dust-0.6.2-aarch64-apple-darwin.tar.xz"
      sha256 "ee8767c05a73b8e1d6817e7597eadc4f2dd2f152f8cdc24896d18c1329b1b6ad"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.6.2-custom/dust-0.6.2-x86_64-apple-darwin.tar.xz"
      sha256 "58651e99991217f185af3dd3390c26cb8d821e2c0bc115f4bb4f3e7eb65cf929"
    end
  end
  license "Apache-2.0"
  head "https://github.com/bootandy/dust.git"

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
