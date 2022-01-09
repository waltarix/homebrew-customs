class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.19.0-custom/bat-0.19.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "6645e5165a6e3a1680b83ddca90ff392dd42a0b9df2c2100c097e3ccf641e859"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.19.0-custom/bat-0.19.0-aarch64-apple-darwin.tar.xz"
      sha256 "f670a7881b348ba6f5ccbb084794d6c1571bcba8156e0081fa69521377165f04"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.19.0-custom/bat-0.19.0-x86_64-apple-darwin.tar.xz"
      sha256 "3a116d4786686f19da7d88ae4e7e54464fc6fa5134ed6298629795dad57a80d5"
    end
  end
  license "Apache-2.0"

  uses_from_macos "zlib"

  def install
    bin.install "bat"
    man1.install "manual/bat.1"
    fish_completion.install "etc/completions/bat.fish"
    zsh_completion.install "etc/completions/bat.zsh" => "_bat"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end
