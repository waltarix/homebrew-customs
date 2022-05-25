class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.12.3-custom/procs-0.12.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "4e16590d86a652438fbb88d7a9e9f9a150f1118991d9a6b6fb98cff149b96e4c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.12.3-custom/procs-0.12.3-aarch64-apple-darwin.tar.xz"
      sha256 "f100819c8cd211c0cba7b3eb52e2134e26363e53a37d8b49e815a3ab06a834d2"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.12.3-custom/procs-0.12.3-x86_64-apple-darwin.tar.xz"
      sha256 "9cd7d39f03bd96c8a16000a82c5230273cfdf56bd766174e393d21acf637689e"
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
