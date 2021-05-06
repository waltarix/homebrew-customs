class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.5-custom/procs-0.11.5-x86_64-unknown-linux-musl.tar.xz"
    sha256 "cd2f5e58de47454e68bd8542b8ca60545a97f355a546b99bb19c8f5fe0b491f4"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.5-custom/procs-0.11.5-aarch64-apple-darwin.tar.xz"
      sha256 "2cfafd8f666e748fcd655f86da175787a86ca60ba0d9c8f76538785c1b12c9fb"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.5-custom/procs-0.11.5-x86_64-apple-darwin.tar.xz"
      sha256 "fce44cb978f6e3964e63a5258e465d0083eccc09e4c48acc280a2f00eb61c5e9"
    end
  end
  license "MIT"

  bottle :unneeded

  def install
    bin.install "procs"

    system "#{bin}/procs", "--completion", "bash"
    system "#{bin}/procs", "--completion", "fish"
    system "#{bin}/procs", "--completion", "zsh"
    bash_completion.install "procs.bash" => "procs"
    fish_completion.install "procs.fish"
    zsh_completion.install "_procs"
  end

  test do
    output = shell_output("#{bin}/procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
