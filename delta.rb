class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.12.1-custom-r1/delta-0.12.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "727eff7fd675e9a6c57f2755b7771320060080d1b15af6b632dd9eb35fb48560"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.12.1-custom-r1/delta-0.12.1-aarch64-apple-darwin.tar.xz"
      sha256 "9949da363d3b3171b575e825bdbaa249523e85b31c678b70e2003ad3c3bf7648"
    else
      url "https://github.com/waltarix/delta/releases/download/0.12.1-custom-r1/delta-0.12.1-x86_64-apple-darwin.tar.xz"
      sha256 "992865ceea4ae59fcf0b3cb2d7d7738a0a1043548fd96d028e17e33a8a6e9355"
    end
  end
  license "MIT"
  revision 1

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
