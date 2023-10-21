class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  "0.14.3".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "c8bb36a00986085f91fd0a0a514b4ba6001e8586394dd4d491c8a128875da412"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "3200590026066cf663cd371bfd090ad1b285ce8b326f07ed5c074ede80f74d12"
      else
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "46258fc8bfc6eafd82873c512b46b7e78507b3903bd1ec67d61267fe181781dd"
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
