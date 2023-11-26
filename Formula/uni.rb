class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  ["2.6.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64.tar.xz"
      sha256 "93b4d223df8c2ea100362f2fc45c5d09a7ff6eb7f3948c63814d750034a3dfdb"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_arm64.tar.xz"
        sha256 "9923fc2a55289da36adf03536ffa7c3dc3b592de3358cf633f910f0a48fea811"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_amd64.tar.xz"
        sha256 "9541248a0be18830cdb4abe494c818bae655f76a3e02ab616ceb513ae9e4fdfc"
      end
    end
    version v
    revision r if r
  end
  license "MIT"

  def install
    bin.install "uni"
  end

  test do
    assert_match "CLINKING BEER MUGS", shell_output("#{bin}/uni identify 🍻")
    assert_equal "☆2\n✓ 1\n", shell_output("#{bin}/uni p -qf '%(char)%(wide_padding)%(cjk_width)' 2606 2713")
  end
end
