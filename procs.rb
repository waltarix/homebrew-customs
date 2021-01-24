class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.10.10-custom-r1/procs-0.10.10-x86_64-unknown-linux-musl.tar.xz"
    sha256 "482c14804affa9583d686924f47ce78e3c896d971706c9c9c3b5befda0f7137b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.10.10-custom-r1/procs-0.10.10-aarch64-apple-darwin.tar.xz"
      sha256 "f542ded44a8e30a0a94e82015e509f1cc3ddb5f81eba708304c7df526588fbda"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.10.10-custom-r1/procs-0.10.10-x86_64-apple-darwin.tar.xz"
      sha256 "483785bab6e57d9c34dc6d7256bc857f8cdc5d7eca68e1f74e6ed7a8d4c524fb"
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
