class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.18.2-custom/bat-0.18.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "67c07b1630356155edcb8b68fefc9cc04363df740baa1f20a4aa527f8e6e5e54"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.18.2-custom/bat-0.18.2-aarch64-apple-darwin.tar.xz"
      sha256 "2fafdb120a1788b4d78bab73f50e88be5d656cff710c7ef304780c360b95db92"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.18.2-custom/bat-0.18.2-x86_64-apple-darwin.tar.xz"
      sha256 "9c8b1ec6039c7316464ef97b972e33c28ccc34ec8990d8e5ea776936f01e0efb"
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
