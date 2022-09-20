class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  if OS.linux?
    url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom-r2/uni-2.5.1-linux_amd64.tar.xz"
    sha256 "995dca962bc60455112b63f84239ba37697cd12d30e5f2bef31a68d670800473"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom-r2/uni-2.5.1-darwin_arm64.tar.xz"
      sha256 "641128508e521bb2b4f9411be75c5eaa4f348ab49b9a49156d769f52957ffa19"
    else
      url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom-r2/uni-2.5.1-darwin_amd64.tar.xz"
      sha256 "0c84f786ff59bd66d02a496f54cfc7c25a0cf3d3ae2c17f70e057015d8948ee5"
    end
  end
  version "2.5.1"
  license "MIT"
  revision 2

  def install
    bin.install "uni"
  end

  test do
    assert_match "CLINKING BEER MUGS", shell_output("#{bin}/uni identify 🍻")
    assert_equal "☆2\n✓ 1\n", shell_output("#{bin}/uni p -qf '%(char)%(wide_padding)%(cjk_width)' 2606 2713")
  end
end
