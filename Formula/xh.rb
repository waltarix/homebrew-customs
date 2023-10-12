class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  "0.19.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "2acd3a6ffd754d6bdb33316c6a35b871532f3619d3c845b18641c8bb031e1547"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "9e91feb5de60c7170295fee6f345c0550cf4ed3e0593d1945a5a2d50efd725be"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "e048562f7be104d996d361826c51fa7f95de8c8d19e423858bcc1b17cb80ebda"
      end
    end
  end
  license "MIT"

  def install
    bin.install "xh"
    bin.install_symlink "xh" => "xhs"

    man1.install "man/xh.1"
    bash_completion.install "completions/xh.bash"
    fish_completion.install "completions/xh.fish"
    zsh_completion.install "completions/_xh"
  end

  test do
    hash = JSON.parse(shell_output("#{bin}/xh -I -f POST https://httpbin.org/post foo=bar"))
    assert_equal hash["form"]["foo"], "bar"
  end
end
