class Delta < Formula
  desc "Syntax-highlighting pager for git and diff output"
  homepage "https://github.com/dandavison/delta"
  if OS.linux?
    url "https://github.com/waltarix/delta/releases/download/0.11.3-custom-r1/delta-0.11.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "3ade62610980873136e7afcb3dcb2769fa416358af09530f0f06dc6358f050ce"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/delta/releases/download/0.11.3-custom-r1/delta-0.11.3-aarch64-apple-darwin.tar.xz"
      sha256 "363372ae7d79602cde1c3d5b109b5a397c34481fd7ca6fc374bb3dc1cfd3dae7"
    else
      url "https://github.com/waltarix/delta/releases/download/0.11.3-custom-r1/delta-0.11.3-x86_64-apple-darwin.tar.xz"
      sha256 "ae5a64ce5ac4d44b0ed05f014ffbb67d742329f1c20495450aaa163b44959225"
    end
  end
  license "MIT"
  revision 1

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
