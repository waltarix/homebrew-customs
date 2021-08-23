class Bat < Formula
  desc "Clone of cat(1) with syntax highlighting and Git integration"
  homepage "https://github.com/sharkdp/bat"
  if OS.linux?
    url "https://github.com/waltarix/bat/releases/download/v0.18.3-custom/bat-0.18.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "e41c6d05c410a6f4dce022ff96bd4d73be5024debd139bc670c65f1543fed2d4"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/bat/releases/download/v0.18.3-custom/bat-0.18.3-aarch64-apple-darwin.tar.xz"
      sha256 "6196b531a8c7c3d3e7788a16364568e8b1b64a2069247d40d265cdd4dbab95bb"
    else
      url "https://github.com/waltarix/bat/releases/download/v0.18.3-custom/bat-0.18.3-x86_64-apple-darwin.tar.xz"
      sha256 "28e0abb7b89aaca20c302c753f7ff8dc4046ea89e051681b06589f8a30c8ec62"
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
