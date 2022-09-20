class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.14.0-custom-r1/delta-0.14.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "36147cdf7e00d38351f199b3045a9fa52cff8c7eb34a1945f97e1c20a8e02d50"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.14.0-custom-r1/delta-0.14.0-aarch64-apple-darwin.tar.xz"
      sha256 "a1d23e988451900e7bed7acc619002d2b559526f8db9e6eee4dad784c4351aff"
    else
      url "https://github.com/waltarix/delta/releases/download/0.14.0-custom-r1/delta-0.14.0-x86_64-apple-darwin.tar.xz"
      sha256 "c328632ad30eb396a352a49ce3ed578d970cabaada6552195ffe5e516f8a6353"
    end
  end
  license "MIT"
  revision 1

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
