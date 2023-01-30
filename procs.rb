class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.13.4-custom/procs-0.13.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "fdc5e22177e0b415cdc3a8201c3138edc6da2714c2fff9f0327dd2037fd6d34b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.13.4-custom/procs-0.13.4-aarch64-apple-darwin.tar.xz"
      sha256 "611f625c6cca15f32d03daa00b69e261796e2c37b48b4cd936f3aee9bed131c0"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.13.4-custom/procs-0.13.4-x86_64-apple-darwin.tar.xz"
      sha256 "daa8d7af5a098e426c2ae51df9d14ed24a7580bb5a43a07ca42eb730ad524aff"
    end
  end
  license "MIT"

  def install
    bin.install "procs"

    generate_completions_from_executable(bin/"procs", "--completion-out")
  end

  test do
    output = shell_output(bin/"procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
