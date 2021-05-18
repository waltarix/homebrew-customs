class Procs < Formula
  desc "Modern replacement for ps written by Rust"
  homepage "https://github.com/dalance/procs"
  if OS.linux?
    url "https://github.com/waltarix/procs/releases/download/v0.11.6-custom/procs-0.11.6-x86_64-unknown-linux-musl.tar.xz"
    sha256 "9514c018313c725d1a11436ff84f4740f1fc7b5e8fe38c909efdd841a66d758a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/procs/releases/download/v0.11.6-custom/procs-0.11.6-aarch64-apple-darwin.tar.xz"
      sha256 "720731a0b5c232ca1b7dd97b637257b71757111119b7f9cbea1d95f7b0040919"
    else
      url "https://github.com/waltarix/procs/releases/download/v0.11.6-custom/procs-0.11.6-x86_64-apple-darwin.tar.xz"
      sha256 "cdeb96fa5643a9daa51028222881f2f63e4481a9b33ab06632597df3057da497"
    end
  end
  license "MIT"

  bottle :unneeded

  def install
    bin.install "procs"

    system "#{bin}/procs", "--completion", "bash"
    system "#{bin}/procs", "--completion", "fish"
    system "#{bin}/procs", "--completion", "zsh"
    bash_completion.install "procs.bash" => "procs"
    fish_completion.install "procs.fish"
    zsh_completion.install "_procs"
  end

  test do
    output = shell_output("#{bin}/procs")
    count = output.lines.count
    assert count > 2
    assert output.start_with?(" PID:")
  end
end
