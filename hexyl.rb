class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.8.0-custom-r1/hexyl-0.8.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "ab081c1fc0a7b6e8323c66af4f73c6ac08014cd6967eca9c791bbffbe47f5546"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.8.0-custom-r1/hexyl-0.8.0-aarch64-apple-darwin.tar.xz"
      sha256 "9f7b2e2e4cc989f6bec2979dc3ccbcf412941e695d38bda4368dcd2588ec1f3f"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.8.0-custom-r1/hexyl-0.8.0-x86_64-apple-darwin.tar.xz"
      sha256 "4f1be2764de89f4a17e4193d80240059c960bbfef094c3fbcce6be140200ebe7"
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
