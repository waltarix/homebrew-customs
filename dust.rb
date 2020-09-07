class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.3-custom/dust-0.5.3-linux.tar.xz"
    sha256 "5ae8136d6e9cbe30b12b59ac4a724c379ab6df5c1896f217244ebe9d1f7297f0"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.3-custom/dust-0.5.3-darwin.tar.xz"
    sha256 "e6156a7b0f1682545d5ac463009068fe65c2ee5c7c5e2ef7c973b153fa69b2a0"
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
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
