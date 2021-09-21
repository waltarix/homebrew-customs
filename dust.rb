class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.7.5-custom/dust-0.7.5-x86_64-unknown-linux-musl.tar.xz"
    sha256 "8df7faac7bf7cf6dcf1fc7d5f5fc195c4b13b5f2b6b22b152646eacaaa3d890d"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.7.5-custom/dust-0.7.5-aarch64-apple-darwin.tar.xz"
      sha256 "ab3f8d36b6c594892a8ec2b41efb072da6a61d8eec78899b43b41b3822ccaa60"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.7.5-custom/dust-0.7.5-x86_64-apple-darwin.tar.xz"
      sha256 "7596bcfcba5bca874633a766895f951e737c06f9205827ca5d6dfa6f91d7d57a"
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
