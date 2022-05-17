class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.13.0-custom/delta-0.13.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "420b0b9494d4b8b31513cdf7d385147206d1e3c221a958359e566f969297427b"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.13.0-custom/delta-0.13.0-aarch64-apple-darwin.tar.xz"
      sha256 "90de1c344d270bfdbc35dfd0731f4567cec08b64aa8fb6bdb8efc3186a45774f"
    else
      url "https://github.com/waltarix/delta/releases/download/0.13.0-custom/delta-0.13.0-x86_64-apple-darwin.tar.xz"
      sha256 "5c6965e2ea28adfd949001e9eeeaccc09251822db0883b2731d87191cac6a77f"
    end
  end
  license "MIT"

  conflicts_with "git-delta", because: "both install a `delta` binary"

  def install
    bin.install "delta"
    man1.install "manual/delta.1"
    bash_completion.install "etc/completion/completion.bash" => "delta"
    zsh_completion.install "etc/completion/completion.zsh" => "_delta"
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
