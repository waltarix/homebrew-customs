class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.7-custom/procs-0.10.7-linux.tar.xz"
    sha256 "6ef9737057b2ec073e335767e62d8c9255a9b3c8dcf3bd7ee82aa7231786e68d"
  else
    url "https://github.com/waltarix/procs/releases/download/v0.10.7-custom/procs-0.10.7-darwin.tar.xz"
    sha256 "c41b435e5aea0c84f0e712a6ee91ca5869c129781fdc0af1d6c20656d0735c5a"
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
