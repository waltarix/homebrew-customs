class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.3-custom/procs-0.11.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "ac8a17982c47adde82f9abc8479696a0c944c7df9677366b4ee8b6518c74a65a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.3-custom/procs-0.11.3-aarch64-apple-darwin.tar.xz"
      sha256 "ce3a56beac6058a3677728df74b47be298e28691e6aaa5696eee007c4b6f25a7"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.3-custom/procs-0.11.3-x86_64-apple-darwin.tar.xz"
      sha256 "0b532b549b983ad054d3fa108997bd403e9b43e9fa3aa885724bd3d1c8dcb58f"
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
