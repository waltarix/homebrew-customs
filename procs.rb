class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.12-custom/procs-0.11.12-x86_64-unknown-linux-musl.tar.xz"
    sha256 "870bfd38e9f06d735f457c6383a8d73d171247b1169809834ed9d8ab5d79bee5"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.12-custom/procs-0.11.12-aarch64-apple-darwin.tar.xz"
      sha256 "88ab57522ccbe6242163291182331fb8b3b1cb44edfa3c5120c674051d738ebd"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.12-custom/procs-0.11.12-x86_64-apple-darwin.tar.xz"
      sha256 "297255daa3a7ef64d07311c3810702c15a38567aaa68ea231dbb82690bc6d082"
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
