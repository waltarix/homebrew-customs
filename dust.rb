class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom/dust-0.5.1-linux.tar.xz"
    sha256 "8e6b0988caa4b4a6565c3e3c3db8a11162d0143026e323a20b9771ed95e603a9"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom/dust-0.5.1-darwin.tar.xz"
    sha256 "f5b682e60c675d8245c11ec488390402ba5a8fe4df395c00f48bd6d2cca9f1b7"
  end

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
