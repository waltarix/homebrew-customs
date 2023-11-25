class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  "0.14.4".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "28013507dee2e241a26d5ceb809014158af96e31e016f023b5607a2db8c383fc"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "1f22f3d2b8709071d383b0c3d33a3f7cd1b3966e564ed00a812225518763f880"
      else
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "f82d225f7c0691650ddee4ca369f357bd3acc5411035d3c0672836ec5227b9ba"
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
