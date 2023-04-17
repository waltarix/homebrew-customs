class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  ["2.5.1", 3].tap do |(v, r)|
    rev = r.nil? ? "" : "-r#{r}"
    if OS.linux?
      url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64.tar.xz"
      sha256 "bd50dfb86d93a74d4cc7d7c077b2940f04395f2868653316da2c33f26e93edba"
    else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_arm64.tar.xz"
      if Hardware::CPU.arm?
        sha256 "b66f84552e11070bcb955a1bb28e97c556e77aae3b588b5a7d2c43026a409200"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_amd64.tar.xz"
        sha256 "2c68a9d58b6ced848a2ba4974780e3607dad630d40b79d31c86a09e53f0c8e2f"
      end
    end
    version v
    revision r unless r.nil?
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
