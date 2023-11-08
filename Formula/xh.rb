class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  ["0.19.4", 1].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "4a11cfab3815abf2ed8dd16d6d9babe779296d5e4286922804267b3ac40098b7"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "20d7655b2eabb26bc33b9ccbaab0498d2dd8844811669fab2e677b17fc106b5b"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "92f9d15006901a3490c8ae121f6d3779b7afff29485231e82a58c45506fd4ef7"
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
