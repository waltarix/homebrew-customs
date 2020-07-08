class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom-r1/dust-0.5.1-linux.tar.xz"
    sha256 "718d5686fc7b22de7108cadfd8ceb8ce439b2f8c493bd13e28c9fbaa29f19b43"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom-r1/dust-0.5.1-darwin.tar.xz"
    sha256 "58563b3b159d23c4c56eb800f2a986b79e7025bd53b270a1e6a307a7101b95d5"
  end
  revision 1

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
