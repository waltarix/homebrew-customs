class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.12.0-custom/procs-0.12.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "1261aa2816725eef68ad955eb04d8788830eb1b021f730fefe6bf5c578ac5f27"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.12.0-custom/procs-0.12.0-aarch64-apple-darwin.tar.xz"
      sha256 "d7d9cc1a105c7a2ebaae8e147cc0c438a9e2d02341ed8266786074032303382d"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.12.0-custom/procs-0.12.0-x86_64-apple-darwin.tar.xz"
      sha256 "4baed718826f76ed4ef29d840708814efe265d57e465ab1caeb51afe7f712a46"
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
