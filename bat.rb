class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.17.1-custom/bat-0.17.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "c18d27c7c7bab272b4c1bf2b5c65886e8b7580bbbe917b05212e988819863c2c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.17.1-custom/bat-0.17.1-aarch64-apple-darwin.tar.xz"
      sha256 "d9f64269e70c3f6a50a712a7cb38a86ba98023da594dc5fd0eba31ac09a429ec"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.17.1-custom/bat-0.17.1-x86_64-apple-darwin.tar.xz"
      sha256 "64a7c17790fe3a4f852b5672e896ed136a8c921f986d6d82ab1ced848170f0f9"
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
