class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  if OS.linux?
    url "https://github.com/waltarix/uni/releases/download/v2.4.0-custom-r1/uni-2.4.0-linux_amd64.tar.xz"
    sha256 "56127718ada670e206a343e1f529f32b2e4aa38e23a89ad06c60eb503be57f91"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/uni/releases/download/v2.4.0-custom-r1/uni-2.4.0-darwin_arm64.tar.xz"
      sha256 "f8c235d4b76931acd8e1e63e37a92778530d4c5d89bc320c4bdedef01e2a8a30"
    else
      url "https://github.com/waltarix/uni/releases/download/v2.4.0-custom-r1/uni-2.4.0-darwin_amd64.tar.xz"
      sha256 "9173dbf54f3da95a4fc0c6324b03ae065cb950ecffcbfc32a27a6ac2cd5f826b"
    end
  end
  version "2.4.0"
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
