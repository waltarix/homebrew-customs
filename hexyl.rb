class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.9.0-custom/hexyl-0.9.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "0d796305bb5555c2d2d37466380b049681d2564af06bb35d094e3a8be0243415"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.9.0-custom/hexyl-0.9.0-aarch64-apple-darwin.tar.xz"
      sha256 "81f4d9cbc76a9ebe61a7a6fbd4b5548e1bbead69a28e8075ad3a4b2bdc4e0266"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.9.0-custom/hexyl-0.9.0-x86_64-apple-darwin.tar.xz"
      sha256 "ce0fbce9273876fa8a38262f965f38a84f9d58e880c96506faee67f7638ddf16"
    end
  end
  license "Apache-2.0"

  bottle :unneeded

  def install
    bin.install "hexyl"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end
