class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.18.1-custom/bat-0.18.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "3a319d369841f879d795f1b353edbedfcacb68b9d3518260ffc8d308c2ad4cb9"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.18.1-custom/bat-0.18.1-aarch64-apple-darwin.tar.xz"
      sha256 "e25d1954f329983de6aa83b87640843619baf4df67eb23f4824751fa91ca0d96"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.18.1-custom/bat-0.18.1-x86_64-apple-darwin.tar.xz"
      sha256 "fef26dd05f63895af7338c41ad7edaa9f026170c8bb39f44a1519464bb5298b5"
    end
  end
  license "Apache-2.0"

  bottle :unneeded

  uses_from_macos "zlib"

  def install
    bin.install "bat"
    man1.install "bat.1"
    fish_completion.install "autocomplete/bat.fish"
    zsh_completion.install "autocomplete/bat.zsh" => "_bat"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end
