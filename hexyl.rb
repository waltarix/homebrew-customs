class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.10.0-custom/hexyl-0.10.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "0cd7045cc9fde0630e04e647f32bd89e64df9d8619857d792a9d83b6e3076493"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.10.0-custom/hexyl-0.10.0-aarch64-apple-darwin.tar.xz"
      sha256 "da4d4baea9dda5525e11ad86f86a57ac8368376fef789cd5d5eb7c92a27d5819"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.10.0-custom/hexyl-0.10.0-x86_64-apple-darwin.tar.xz"
      sha256 "846cde353ada933901570a6f423a7e89485fbf19de353640e89d404eee6205f8"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

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
