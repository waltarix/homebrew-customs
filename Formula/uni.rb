class Uni < Formula
  desc "Unicode database query tool for the command-line"
  homepage "https://github.com/arp242/uni"
  ["2.7.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64_v2.tar.xz"
        sha256 "213bd4005129fb2bd28d52bb11972bbd75888a0415d6879b3e42fcd83fe15a8b"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-linux_amd64_v4.tar.xz"
        sha256 "394b43e30310d387ecfac9673fc6c7de8b869154003d62a43011a9467e133c01"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_arm64.tar.xz"
        sha256 "f4efc1e8a5e5beb31a2edfd62968d59158ba97dafb9004b66fc71eb2e55e0375"
      else
        url "https://github.com/waltarix/uni/releases/download/v#{v}-custom#{rev}/uni-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "610f0450950ba474aad2208d920bf7760d0b236a7c6b6b68185c82ca5edc2136"
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
