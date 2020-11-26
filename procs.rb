class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.10-custom/procs-0.10.10-linux.tar.xz"
    sha256 "0c9e5696ada22d94071e1e8aca5630d3c8a334dafe7f35311463f859541a48be"
  else
    url "https://github.com/waltarix/procs/releases/download/v0.10.10-custom/procs-0.10.10-darwin.tar.xz"
    sha256 "baf3955e6cd67849f9ba842427839df2c4944cb5b2d9601d3593e66bdfc535a9"
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
