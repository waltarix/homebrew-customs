class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.3-custom/procs-0.10.3-linux.tar.xz"
    sha256 "bc7522d71833a19575e672786cc3648bbc0df42fe9a7ca402d41856eddfc26d5"
  else
    url "https://github.com/waltarix/procs/releases/download/v0.10.3-custom/procs-0.10.3-darwin.tar.xz"
    sha256 "8ef66180ac75bf833437fe6ae5f114f61b283b06be0c22402944e9f9eb120515"
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
