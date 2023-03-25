class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.23.0-custom/bat-0.23.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "c0b30bb5fdbd313576ca4bfa89766d6998afae9f2b6ac561f29f6772ef1e68ed"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.23.0-custom/bat-0.23.0-aarch64-apple-darwin.tar.xz"
      sha256 "ea41c30d571ac68223ac40f12af54f85c74cb9761e7115cdd13a55a2f6a1ea6d"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.23.0-custom/bat-0.23.0-x86_64-apple-darwin.tar.xz"
      sha256 "ddf0a73791441a0b25b434a1d77ef1c5d93c080493c5140d3ebfcdd5f610b45b"
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

  def install
    bin.install "bat"
    man1.install "manual/bat.1"
    bash_completion.install "etc/completions/bat.bash" => "bat"
    fish_completion.install "etc/completions/bat.fish"
    zsh_completion.install "etc/completions/bat.zsh" => "_bat"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/bat #{pdf} --color=never")
    assert_match "Homebrew test", output
  end
end
