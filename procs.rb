class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.7-custom/procs-0.11.7-x86_64-unknown-linux-musl.tar.xz"
    sha256 "1a3e1fc0533a0a70e176e9fa78462beda0f4e08e2052237c747b541bf2a9bfdd"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.7-custom/procs-0.11.7-aarch64-apple-darwin.tar.xz"
      sha256 "a30adaf1de71189ed1fd5145321c3fdbc4b1d7dc1eff5c5e7d86abd2420ffb8e"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.7-custom/procs-0.11.7-x86_64-apple-darwin.tar.xz"
      sha256 "84208747bdb5014a99511415814dad856144d9234181ad45fc5bff711d0ffbf6"
    end
  end
  license "MIT"

  bottle :unneeded

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
