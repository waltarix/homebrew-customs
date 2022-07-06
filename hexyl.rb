class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.10.0-custom-r1/hexyl-0.10.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "cf77ad3a2fc5b4ede43a0f619dbcc2ce0cfbbb38f6f41e6c1b33f00f9544b25e"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.10.0-custom-r1/hexyl-0.10.0-aarch64-apple-darwin.tar.xz"
      sha256 "9be58e71a08b4a7f6d913527e4aef691fcc4f58acf4e36f80c16eeedee3ab2db"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.10.0-custom-r1/hexyl-0.10.0-x86_64-apple-darwin.tar.xz"
      sha256 "45dde93cdb0fea8dff5142059bb57b573679b537fc49096059c91d00b8577cfc"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]
  revision 1

  def install
    bin.install "hexyl"
    man1.install "manual/hexyl.1"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end
