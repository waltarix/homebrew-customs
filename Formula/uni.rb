class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  ["2.5.1", 4].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64.tar.xz"
      sha256 "bf64cadec0403fd12e9edc77429813fbc9669f4e973c816751579c862646b9a4"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_arm64.tar.xz"
        sha256 "03ca2e2960d6a27d04dde64239d2ecebf2be9fa675292dad605b9bd40f454f44"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_amd64.tar.xz"
        sha256 "75a930eb36bafc069a9735331b0a6145eb89dd7a3d8bab463fafe60c3701cbf4"
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
