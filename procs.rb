class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.12.2-custom/procs-0.12.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "c5dd23782cc73499080a0a534275da1a18ab928830e1e731739c5f47a8d613ae"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.12.2-custom/procs-0.12.2-aarch64-apple-darwin.tar.xz"
      sha256 "1041c1761eb2713700c0fdaa11a0f650f463d2efbfb15a130d3953d96923ca96"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.12.2-custom/procs-0.12.2-x86_64-apple-darwin.tar.xz"
      sha256 "006e3a169d64f036770192a7abc6831dc415ef7834ae0eb49ad5ccec766e4395"
    end
  end
  license "MIT"

  def install
    bin.install "procs"

    system bin/"procs", "--completion", "bash"
    system bin/"procs", "--completion", "fish"
    system bin/"procs", "--completion", "zsh"
    bash_completion.install "procs.bash" => "procs"
    fish_completion.install "procs.fish"
    zsh_completion.install "_procs"
  end

  test do
    output = shell_output(bin/"procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
