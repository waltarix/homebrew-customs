class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  "0.14.10".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "dde0209a376c0b0b160be12b1acf66e4841c358fba2317277c3647ef0aa06373"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "ab786d7dfb561e7da0271fbca971faa9d99bc7e00a940e74d928634149be5d54"
      else
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "698471754039dd0f6cc3429efebdf617254ec7d81fa7651c5b7bb3af35e616a8"
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
