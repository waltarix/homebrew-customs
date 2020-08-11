class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.4-custom/procs-0.10.4-linux.tar.xz"
    sha256 "b0fb4a2e9921bdae43994d5a4b012ef018cfe7d89636c7d685a2e285e0b3d2f4"
  else
    url "https://github.com/waltarix/procs/releases/download/v0.10.4-custom/procs-0.10.4-darwin.tar.xz"
    sha256 "a9179232c7184eb01d061f9e38c67adab13953e1df0ca431ac85f53562da8a62"
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
