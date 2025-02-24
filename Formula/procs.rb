class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  "0.14.9".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "31abf911b6c232c02f0f35388ce22f33d4543fd095142ba8b70346e885e2955d"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "4bb1fb05745d80802283a580ee44b7f9f3c3b5511446dbe6a58a69bac88ca8a6"
      else
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "2c0aca12e0bc0a0b4acd08c5628276dacf393165b8ab88094d37ae8e1e61304d"
      end
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
