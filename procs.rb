class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.4-custom/procs-0.11.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "75d9930d251e43bceca20e6ac58539f30878a92f52a42a905d12775ca1f68266"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.4-custom/procs-0.11.4-aarch64-apple-darwin.tar.xz"
      sha256 "ccbd16c0dd2ef7957a489de314cc3fc65c601d24230629d849e32f0ab2da3526"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.4-custom/procs-0.11.4-x86_64-apple-darwin.tar.xz"
      sha256 "7a9edd482bf8ff9c27c217da0f59deacda4ffbd037af55bcdf3ed542bdf93e4e"
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
