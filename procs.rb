class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.13.1-custom/procs-0.13.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "00c0c07d81b93cb2f38b375c85fc7d54da777f77ce5e7bfb3558d8bff1b42e0a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.13.1-custom/procs-0.13.1-aarch64-apple-darwin.tar.xz"
      sha256 "4df25066dd9fc4c4527683368f4171032132877943acbd80f23fb6dfa54aaad4"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.13.1-custom/procs-0.13.1-x86_64-apple-darwin.tar.xz"
      sha256 "6bd72bb4445d0c84ea2ea7a7bcfa35534df59cf9a9aa8c39e7ecc883bd014f93"
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
