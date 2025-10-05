class ChromeCli < Formula
  desc "Control Google Chrome from the command-line"
  homepage "https://github.com/prasmussen/chrome-cli"
  url "https://github.com/waltarix/chrome-cli/releases/download/1.11.0-custom/chrome-cli-1.11.0-aarch64-apple-darwin.tar.xz"
  sha256 "8918a0c1e15b96e0573448df169bf115b91336549087f891e57261206ccff38b"
  version "1.11.0"
  license "MIT"

  depends_on :macos

  def install
    bin.install "chrome-cli"

    # Install wrapper scripts for chrome compatible browsers
    bin.install "scripts/chrome-canary-cli"
    bin.install "scripts/chromium-cli"
    bin.install "scripts/brave-cli"
    bin.install "scripts/vivaldi-cli"
    bin.install "scripts/edge-cli"
    bin.install "scripts/arc-cli"
  end

  test do
    system bin/"chrome-cli", "version"
  end
end
