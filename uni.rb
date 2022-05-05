class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  if OS.linux?
    url "https://github.com/waltarix/uni/releases/download/v2.5.0-custom/uni-2.5.0-linux_amd64.tar.xz"
    sha256 "0647afa833f70f3f5ae9d06bafcf49d060614b3485d4e8c3b1099594138b54bb"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/uni/releases/download/v2.5.0-custom/uni-2.5.0-darwin_arm64.tar.xz"
      sha256 "ceb57cc3accaff5233691a1e9ac62fcbcc805294d480517cd97818fd1fbb77c6"
    else
      url "https://github.com/waltarix/uni/releases/download/v2.5.0-custom/uni-2.5.0-darwin_amd64.tar.xz"
      sha256 "17412e62b234d0a494b7e695a680ebdb13b591120a7f204339cedc25f0f4baed"
    end
  end
  version "2.5.0"
  license "MIT"

  def install
    bin.install "uni"
  end

  test do
    assert_match "CLINKING BEER MUGS", shell_output("#{bin}/uni identify 🍻")
    assert_equal "☆2\n✓ 1\n", shell_output("#{bin}/uni p -qf '%(char)%(wide_padding)%(cjk_width)' 2606 2713")
  end
end
