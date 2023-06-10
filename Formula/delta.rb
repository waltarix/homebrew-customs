class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  "0.16.5".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/delta/releases/download/#{v}-custom/delta-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "b378e24fcaa489dc6c45af44bb7b89e43ca0d0ca33496d470bb68266b1cdb934"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/delta/releases/download/#{v}-custom/delta-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "f07af8d7c5b997fc7455f137e71434043b1e24605af1904ae577e90a69ceb89d"
      else
        url "https://github.com/waltarix/delta/releases/download/#{v}-custom/delta-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "091d7430aa08ef69696e69d89259a9c411e6cd26f58c1ccdae302106538471c1"
      end
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
