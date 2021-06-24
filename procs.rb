class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.9-custom/procs-0.11.9-x86_64-unknown-linux-musl.tar.xz"
    sha256 "bc0935d80aa1735c0d0029d81f31f0f39cbeb684b2a425924661c8ae8f862f8d"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.9-custom/procs-0.11.9-aarch64-apple-darwin.tar.xz"
      sha256 "7c22380d2545916a84dddb18c67340bc81d63b589cab66264e32b1e4af992338"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.9-custom/procs-0.11.9-x86_64-apple-darwin.tar.xz"
      sha256 "c95b3013eb7d26ce141a997a2e806bbe92360c2a58bf123d53c51e88dab15a9f"
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
