class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.11.3-custom/delta-0.11.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "a4d59e7f43f5cb31f1ccb66759d232e1842954f9d7a83568e888959b49a660ea"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.11.3-custom/delta-0.11.3-aarch64-apple-darwin.tar.xz"
      sha256 "3e114c8059348651e5aaa48535978a02f2c48354353e3d53d0592771942193a3"
    else
      url "https://github.com/waltarix/delta/releases/download/0.11.3-custom/delta-0.11.3-x86_64-apple-darwin.tar.xz"
      sha256 "17ecc82c555cf6cbae6cb4fbb77a93620584e2e32229556badb94b043506cc7a"
    end
  end
  license "MIT"

  conflicts_with "git-delta", because: "both install a `delta` binary"

  def install
    bin.install "delta"
    bash_completion.install "etc/completion/completion.bash" => "delta"
    zsh_completion.install "etc/completion/completion.zsh" => "_delta"
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
