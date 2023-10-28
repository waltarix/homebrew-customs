class Xh < Formula
  desc "Friendly and fast tool for sending HTTP requests"
  homepage "https://github.com/ducaale/xh"
  "0.19.4".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/xh/releases/download/v#{v}-custom/xh-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "c73ebcce8a1683038bde677979d289deb8670ff70d3203ba367fdbe140d15656"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom/xh-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "66a787cdd28c1c13bc9b3ad9f5a72bd173b3722f4736ef5c0a0f2f95733169fb"
      else
        url "https://github.com/waltarix/xh/releases/download/v#{v}-custom/xh-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "827e5ccc54f894a2a7ea912e65775e356c09144c3e23386e8351db77cfb31af6"
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
