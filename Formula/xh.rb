class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  if OS.linux?
    url "https://github.com/waltarix/xh/releases/download/v0.18.0-custom/xh-0.18.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "030786d9a4f4d63857137642c5cb9851b46230c6591b8fcffd4e4f15924abda1"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/xh/releases/download/v0.18.0-custom/xh-0.18.0-aarch64-apple-darwin.tar.xz"
      sha256 "92efb77a1411b74b16b4d8c32df5f23c9eed90b7d65eabcc44df2669923dd426"
    else
      url "https://github.com/waltarix/xh/releases/download/v0.18.0-custom/xh-0.18.0-x86_64-apple-darwin.tar.xz"
      sha256 "f853c6bed26fa99c36d361076e4befaecc4843adee1dc71be9aff4c9339b41d2"
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
