class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  ["2.8.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64_v2.tar.xz"
        sha256 "77f0664f2ef4ecb6313a30842e4873f44a1b7728bd3ee8a136cef1b9d1990fa9"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64_v4.tar.xz"
        sha256 "3543b14eb246ebb932ff31079d88aab3d47ce6263f18c0918888722e6830c311"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_arm64.tar.xz"
        sha256 "9adb14e7fc21d7853581ed42634ee7d81b770d609f1908b532e4c6e06b13d5d3"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "b1b472cbe59317d1309add17c3c81bb714034ebd9e9de27a27b4f19536f8c10d"
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
