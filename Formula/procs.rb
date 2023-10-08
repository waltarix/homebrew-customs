class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  "0.14.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "15eaa9216bd9dfd4e83f6013fa194b154cbd3dc82c0f4602d4c54a7ce4f30fc9"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "1b70526a201e26a3581fdd5eedb669b70870002157e1520754883ab38ad3ecfa"
      else
        url "https://github.com/waltarix/procs/releases/download/v#{v}-custom/procs-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "af9d71c844fe668b4639124535d6b6628d0a24599d4f8d0c3079a3ea30a73374"
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
