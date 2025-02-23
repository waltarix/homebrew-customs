class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  "0.18.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/delta/releases/download/#{v}-custom/delta-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "86981260f34b992a46ab12b3e66461390ccecaa1a92da1fb95085f158ff0e32b"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/delta/releases/download/#{v}-custom/delta-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "a0e69300a3de64b1d21464a905caa2b21b5bd752fbd19f66c5b64574ed6d721f"
      else
        url "https://github.com/waltarix/delta/releases/download/#{v}-custom/delta-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "52c7f197dc7b10cadc31d2853b0d727b67ebeae28ad9681b3168e0eb16477bdf"
      end
    end
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
