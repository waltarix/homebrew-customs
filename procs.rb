class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.8-custom/procs-0.10.8-linux.tar.xz"
    sha256 "851a6eb30bb199edc04daab1f9507d3a048a0e0bbc3763dc5bbe988f86322874"
  else
    url "https://github.com/waltarix/procs/releases/download/v0.10.8-custom/procs-0.10.8-darwin.tar.xz"
    sha256 "2ee86495b41b6cb8af799c45bc26e5fd24cfe08f49c4515ade9d54050576b7ad"
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
