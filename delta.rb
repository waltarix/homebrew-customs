class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.12.0-custom/delta-0.12.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "f63faa95f14ce90234e16ce87a0a1a95c496f4a3e723be76d814f0f306852dc0"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.12.0-custom/delta-0.12.0-aarch64-apple-darwin.tar.xz"
      sha256 "a7aa342ae4aacbae1692f9273d21a27a2088a75531d8403c208e81b6495be845"
    else
      url "https://github.com/waltarix/delta/releases/download/0.12.0-custom/delta-0.12.0-x86_64-apple-darwin.tar.xz"
      sha256 "f2b92e27d81533c947ff80d05162faf0de256b04ec7d0aaeb204c5facc5ace7a"
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
