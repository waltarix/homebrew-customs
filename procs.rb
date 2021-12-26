class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.13-custom/procs-0.11.13-x86_64-unknown-linux-musl.tar.xz"
    sha256 "c437b9bf7cc1be1375ea71a4ed21ef53c1b505a2cd83ef997546603819a09ffd"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.13-custom/procs-0.11.13-aarch64-apple-darwin.tar.xz"
      sha256 "daafdee9feaa7dea56a84086bd7ca9eb5aadb23486f0b9181f12db11c2a57abb"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.13-custom/procs-0.11.13-x86_64-apple-darwin.tar.xz"
      sha256 "15b824ed91ebe69013d640231e3464966af1080ab63ed45c34f3db79cd4b3afe"
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
