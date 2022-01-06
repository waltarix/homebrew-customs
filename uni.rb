class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  if OS.linux?
    url "https://github.com/waltarix/uni/releases/download/v2.4.0-custom/uni-2.4.0-linux_amd64.tar.xz"
    sha256 "71f4ea5e292172cf3c606ad48644b3c341e5831fd0caf5c8cc266f54da0c7809"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/uni/releases/download/v2.4.0-custom/uni-2.4.0-darwin_arm64.tar.xz"
      sha256 "65bdad0822ef410a89035e46b7d7163c034d0dc0d94a160c147fbfe2d8a58d8c"
    else
      url "https://github.com/waltarix/uni/releases/download/v2.4.0-custom/uni-2.4.0-darwin_amd64.tar.xz"
      sha256 "843dcb1e0e6b3333ef2faaa463e149998fb9ab323eb431fd2b65c9a706a231d1"
    end
  end
  version "2.4.0"
  license "MIT"

  def install
    bin.install "uni"
  end

  test do
    assert_match "CLINKING BEER MUGS", shell_output("#{bin}/uni identify 🍻")
    assert_equal "☆2\n✓ 1\n", shell_output("#{bin}/uni p -qf '%(char)%(wide_padding)%(cjk_width)' 2606 2713")
  end
end
