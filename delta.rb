class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.14.0-custom/delta-0.14.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "26d6e3093828be47a38597baed80b42401176fa8e52a2eec4d5adde748f3a18c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.14.0-custom/delta-0.14.0-aarch64-apple-darwin.tar.xz"
      sha256 "600b526145ba2a191017ae32c4c61dbbe34098c854278feddf1cbfaea7658805"
    else
      url "https://github.com/waltarix/delta/releases/download/0.14.0-custom/delta-0.14.0-x86_64-apple-darwin.tar.xz"
      sha256 "794a8abee93e3138a78d1e9aeb39ffd87b7b1b37d9d0947b86337022b419cb45"
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
