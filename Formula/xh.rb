class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  ["0.24.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "130b540a98b66bbdbc1668ee66e12ae4dce3e8c87149134c82033a30262a859f"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "6d9e38a5465d849d779adfb887d9b411c79607a05b514477bdb2ff2d7b8ac549"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom#{rev}/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "91c3b53b6cc938eaa6eceebed663790f7b142eeb1fea5af5c45087e0ed7712b1"
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
