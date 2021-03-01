class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.18.0-custom/bat-0.18.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "04fd754f1bf4f602ae3f4020cd0544604a3e0f7c17bcf7cfad133a45baf2e2e2"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.18.0-custom/bat-0.18.0-aarch64-apple-darwin.tar.xz"
      sha256 "53c9f0551427eed691b4ce7cf2d705b9fd348d6833d40a6895fc635284be5b35"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.18.0-custom/bat-0.18.0-x86_64-apple-darwin.tar.xz"
      sha256 "8992f324019e248fc3a90ef2dc12140cc6e8181dc824630962734226bacfeb11"
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
