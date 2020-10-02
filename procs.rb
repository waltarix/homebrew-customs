class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.5-custom/procs-0.10.5-linux.tar.xz"
    sha256 "64e4551f842a34e65f8a320ffe6df2fafb5a49735a2ba0d6a060035aec0a3a2e"
  else
    url "https://github.com/waltarix/procs/releases/download/v0.10.5-custom/procs-0.10.5-darwin.tar.xz"
    sha256 "9c8656616309b2835f2ae6537efc2fa6cc7ccb80a0b536412c4347ada52be0f0"
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
