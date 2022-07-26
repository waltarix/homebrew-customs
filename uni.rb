class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  if OS.linux?
    url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom-r1/uni-2.5.1-linux_amd64.tar.xz"
    sha256 "8753881b6f264f0f497753231d88be1a902b7e76ee717a2138df1cb418d31ea1"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom-r1/uni-2.5.1-darwin_arm64.tar.xz"
      sha256 "ba3231a7628c8210873808e6575d946209911af934cd14a6991a1a5c0694aac3"
    else
      url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom-r1/uni-2.5.1-darwin_amd64.tar.xz"
      sha256 "c2f4598e4c0ba9dc247c85d144b60ca404098bb040348b25b34e62642429cc4c"
    end
  end
  version "2.5.1"
  license "MIT"
  revision 1

  def install
    bin.install "uni"
  end

  test do
    assert_match "CLINKING BEER MUGS", shell_output("#{bin}/uni identify 🍻")
    assert_equal "☆2\n✓ 1\n", shell_output("#{bin}/uni p -qf '%(char)%(wide_padding)%(cjk_width)' 2606 2713")
  end
end
