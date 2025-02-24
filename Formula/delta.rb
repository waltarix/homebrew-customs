class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  ["0.18.2", 1].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/delta/releases/download/#{v}-custom#{rev}/delta-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "2a1860751a25883e5a09e70e0e47092846e3e046f2a5dc00c614e568de03da55"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/delta/releases/download/#{v}-custom#{rev}/delta-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "3cde8ec359e20d847020765ee4aadb182faa724ae31878d76543ed859a653551"
      else
        url "https://github.com/waltarix/delta/releases/download/#{v}-custom#{rev}/delta-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "daf93ee908899a6694c32b6c0f98b21515f869cd912609d190ae8e20820014e9"
      end
    end
    revision r if r
  end
  license "MIT"

  conflicts_with "git-delta", because: "both install a `delta` binary"

  def install
    bin.install "delta"
    man1.install "manual/delta.1"
    generate_completions_from_executable(bin/"delta", "--generate-completion")
  end

  test do
    assert_match "delta #{version}", `#{bin}/delta --version`.chomp
  end
end
