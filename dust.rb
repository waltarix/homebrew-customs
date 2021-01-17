class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.4-custom/dust-0.5.4-linux.tar.xz"
    sha256 "9564362bd0f7f04deac2abb12d46242ac75d489aeffab94f1ae5b4978b4dd98b"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.4-custom/dust-0.5.4-darwin.tar.xz"
    sha256 "817bc534330da270541cc1fda87215b4ab3817b264c4d92ed9e99de5029d0482"
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
