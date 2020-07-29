class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom-r3/dust-0.5.1-linux.tar.xz"
    sha256 "095d85fe9f73ab3f07c94dffe3c370b4c105980b9e8ebd7246011a9964187a23"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom-r3/dust-0.5.1-darwin.tar.xz"
    sha256 "7b4ecef3b77d2d028262b3df760e60c614ef7919e1c52ca8b3cc096ace643e36"
  end
  license "Apache-2.0"
  revision 3

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
