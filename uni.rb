class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  if OS.linux?
    url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom/uni-2.5.1-linux_amd64.tar.xz"
    sha256 "7dc259d66dcace15a0a7cea6a5844d17c278c25fa9142b3a83382cf6c2a86bf8"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom/uni-2.5.1-darwin_arm64.tar.xz"
      sha256 "7e3c91085f6b9e7470cfabab4511ad70fa18438791985a60e943de8bde843a06"
    else
      url "https://github.com/waltarix/uni/releases/download/v2.5.1-custom/uni-2.5.1-darwin_amd64.tar.xz"
      sha256 "08456b01857c3e9409f11d7afe4b9551fbdb07ab84da8c06efcd2aaa347d6dab"
    end
  end
  version "2.5.1"
  license "MIT"

  def install
    bin.install "uni"
  end

  test do
    assert_match "CLINKING BEER MUGS", shell_output("#{bin}/uni identify 🍻")
    assert_equal "☆2\n✓ 1\n", shell_output("#{bin}/uni p -qf '%(char)%(wide_padding)%(cjk_width)' 2606 2713")
  end
end
