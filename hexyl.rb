class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.9.0-custom-r1/hexyl-0.9.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "92f9edf96a7dbf8941a4621e92811a6faba8e05663cb52db66d3b0c642fb5b2b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.9.0-custom-r1/hexyl-0.9.0-aarch64-apple-darwin.tar.xz"
      sha256 "82c971b4eb6406260a5d60c395948f01ce51f1312729e6463ebe5434c8fcc9d1"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.9.0-custom-r1/hexyl-0.9.0-x86_64-apple-darwin.tar.xz"
      sha256 "ec2fd91cb812fa2f9dd53c5bf88da2af63bfdfda97fae9acadaac22cca767b14"
    end
  end
  license "Apache-2.0"
  revision 1

  def install
    bin.install "hexyl"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end
