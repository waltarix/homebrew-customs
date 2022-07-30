class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.13.0-custom/procs-0.13.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "87eb6373e58ad96ea8ac1fbd0ae07aaf516bc3e92f12d9837f200ed41f0e928e"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.13.0-custom/procs-0.13.0-aarch64-apple-darwin.tar.xz"
      sha256 "a98c35b2f907ea1a3b71557a317d16e10e63bac86c00e423e6eaddc65d7683a5"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.13.0-custom/procs-0.13.0-x86_64-apple-darwin.tar.xz"
      sha256 "34aae3ef803edd3bc6652f8eb936faa5882d9a968aee01cb482988e8cc5842f9"
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
