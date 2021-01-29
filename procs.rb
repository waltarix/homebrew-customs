class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.2-custom/procs-0.11.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "e66c1f9bb4b158d268553dc714fe81b363e09306d2b44f502abd65707dc0535d"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.2-custom/procs-0.11.2-aarch64-apple-darwin.tar.xz"
      sha256 "933e1465bc0a7f0fc7eab7732156fa71f8b56b12d6a9639eb41b821d3cd6862c"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.2-custom/procs-0.11.2-x86_64-apple-darwin.tar.xz"
      sha256 "0c8e6efda9c7b2be3e2380801577089b399a28a8eef57ba8a1590bec60b9d96b"
    end
  end
  license "MIT"

  bottle :unneeded

  def install
    bin.install "procs"
  end

  test do
    output = shell_output("#{bin}/procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
