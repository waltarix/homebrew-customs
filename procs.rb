class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.8-custom/procs-0.11.8-x86_64-unknown-linux-musl.tar.xz"
    sha256 "5f05e026d79b9126681c2b0b453a4f0cbb27327ccac85b86ec6a59b8a47c26a7"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.8-custom/procs-0.11.8-aarch64-apple-darwin.tar.xz"
      sha256 "a4583154af85ccb7c871ba2ad76a1842abcb7b0bcf6dcbd94ef31bcf365bbbc1"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.8-custom/procs-0.11.8-x86_64-apple-darwin.tar.xz"
      sha256 "a9f55965bb89ece107f9d205186ded7694885483ddd2b03a6c0d58d4ba85e6c5"
    end
  end
  license "MIT"

  bottle :unneeded

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
