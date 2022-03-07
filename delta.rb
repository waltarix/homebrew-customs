class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.12.1-custom/delta-0.12.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "5f29660bad06bb3efd378456ed3a37c9cc26301b5bc38bcc68b93a0c5d60127a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.12.1-custom/delta-0.12.1-aarch64-apple-darwin.tar.xz"
      sha256 "5af9ce470019658ea8330e47714487c0578a49f641de3b0b0a8f8f74b1fa0bc7"
    else
      url "https://github.com/waltarix/delta/releases/download/0.12.1-custom/delta-0.12.1-x86_64-apple-darwin.tar.xz"
      sha256 "ceeb2dfa04687de7cf03681a506929b09a621279157cd773f51acc4f2e93a81a"
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
