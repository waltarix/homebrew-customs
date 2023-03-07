class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.14.0-custom/procs-0.14.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "cc0ccbfb22fea6028d0714cfafa976e207dee6ca49355d2988904e600a219090"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.14.0-custom/procs-0.14.0-aarch64-apple-darwin.tar.xz"
      sha256 "7ffb6dd54491ea532efe55b7252e645af63beeed7b47c2166eaf7586b906864c"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.14.0-custom/procs-0.14.0-x86_64-apple-darwin.tar.xz"
      sha256 "f08bb79b823e33e3bc8665cbdbe3cea068446b8ff24c8ffd71349bd48f7e5096"
    end
  end
  license "MIT"

  def install
    bin.install "procs"

    generate_completions_from_executable(bin/"procs", "--gen-completion-out")
  end

  test do
    output = shell_output(bin/"procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
