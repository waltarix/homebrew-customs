class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.10-custom/procs-0.11.10-x86_64-unknown-linux-musl.tar.xz"
    sha256 "753ff1b9118285a35acaf44d349fc8362d089672030e2215ffe9b6799f80316e"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.10-custom/procs-0.11.10-aarch64-apple-darwin.tar.xz"
      sha256 "92127bf3d007603f73214f592e094b6dd1e135a115d8aad6f0fbfbb48183fcf6"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.10-custom/procs-0.11.10-x86_64-apple-darwin.tar.xz"
      sha256 "32394f75dcd6c0329cef18871ea3afbc23938479901d79360b99f2e9815406b1"
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
