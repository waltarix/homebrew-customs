class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.15.1-custom/delta-0.15.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "2050472410e36106a23580a38eac64b49200c5829cba803ead443743add2c4fc"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.15.1-custom/delta-0.15.1-aarch64-apple-darwin.tar.xz"
      sha256 "e7a956bef36373d3edba1afb618a7d922838ffad9284a91d071f1f24c76ddcde"
    else
      url "https://github.com/waltarix/delta/releases/download/0.15.1-custom/delta-0.15.1-x86_64-apple-darwin.tar.xz"
      sha256 "9f7e4023c3595d096d567fe6ef9239dad75631d39bfcd63cade223109a37ff54"
    end
  end
  license "MIT"

  conflicts_with "git-delta", because: "both install a `delta` binary"

  def install
    bin.install "delta"
    man1.install "manual/delta.1"
    bash_completion.install "etc/completion/completion.bash" => "delta"
    fish_completion.install "etc/completion/completion.fish" => "delta.fish"
    zsh_completion.install "etc/completion/completion.zsh" => "_delta"
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
