class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.13.2-custom/procs-0.13.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "01180c4a65f6de16de1fdf2276eb16e395f6bb52db293135dd483067dff05b99"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.13.2-custom/procs-0.13.2-aarch64-apple-darwin.tar.xz"
      sha256 "0951f306eaef262590bf30005523680c50b2f7e349098ee7a217d1fb3a6e935d"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.13.2-custom/procs-0.13.2-x86_64-apple-darwin.tar.xz"
      sha256 "ffa0d0a83fd84eb1bdc64a67f3206a82f54525a46eaf6dfac231861f55ff77b0"
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
