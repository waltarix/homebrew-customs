class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  ["0.25.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "0e1764d1dcedc6053c5568a1821a60471b283d60243b64f44265cc1de475635a"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "01005eb59f0a2e23ae243d6a9ff4caf13080550672c1518d4e00f269e58c2f68"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "3897ea2813234cfc3b79f4e1ffdba6344647d7a3ad2b594acf34cd44db9b18c2"
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
