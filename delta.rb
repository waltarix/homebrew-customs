class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.11.3-custom-r2/delta-0.11.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "1f4046abd79136efedad2b7174edb0e7b12bb16b62d0c08ab339609937a273d5"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.11.3-custom-r2/delta-0.11.3-aarch64-apple-darwin.tar.xz"
      sha256 "aeff4a29410a3a7347199204929fc0eccb812a2fe8290c78b7f0ce9db708b845"
    else
      url "https://github.com/waltarix/delta/releases/download/0.11.3-custom-r2/delta-0.11.3-x86_64-apple-darwin.tar.xz"
      sha256 "f160ac8a952b4c7a5d44a4154114e016a210625c60398dd416b28c021ff5cbc6"
    end
  end
  license "MIT"
  revision 2

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
