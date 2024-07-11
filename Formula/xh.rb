class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  ["0.22.2", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "a3a190a508d1e45b44ffbe3b6cc317b56b0d4f6a8c3f43ad58beb88e9936e7b8"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "60344c5a3f908558cc2123c9dce0b329402917d80bc445b001feb8a2ab465d10"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "b2452baccf44f0f793dc60748413dafce1bfa02d5091a8134aeb31ffad16d542"
      end
    end
    revision r if r
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
