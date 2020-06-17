class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom/dust-0.5.1-linux.tar.xz"
    sha256 "16845434352c97fa0d46313ffdc8b700927712d11f44abb3ae37594ed6d3b885"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom/dust-0.5.1-darwin.tar.xz"
    sha256 "10f34bb0ce7b47e97d3a2a60a2ac60803cf6d23757be56a5f0400c8eab9e8f72"
  end

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
