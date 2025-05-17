class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  ["0.24.1", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "4b770cd7998d41f6c076f0fe457fee830e227a75f320d2187107feefb12f2ee0"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "471ba23028eb01915279c010bb6ea08063670667949171450c9a7cd732dc203a"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "64d2de393b6ea95f8b38a6d2a0a5cbf3f0c6ae3b498de6cc4b04e2b2b1eb18d0"
      end
    end
    revision r if r
  end
  license "MIT"

  def install
    bin.install "xh"
    bin.install_symlink "xh" => "xhs"

    man1.install "man/xh.1"
    bash_completion.install "completions/xh.bash" => "xh"
    fish_completion.install "completions/xh.fish"
    zsh_completion.install "completions/_xh"
  end

  test do
    hash = JSON.parse(shell_output("#{bin}/xh -I -f POST https://httpbin.org/post foo=bar"))
    assert_equal hash["form"]["foo"], "bar"
  end
end
