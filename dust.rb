class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.4-custom/dust-0.8.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "6e1cfdc0981063654a7c33565140f787a10fda75c2230f263897eb8f8f53501e"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.4-custom/dust-0.8.4-aarch64-apple-darwin.tar.xz"
      sha256 "9a97cb601f35de5b2ce83c6d37a1d2ab4965db8b2c2dbb7866ee1351998df366"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.4-custom/dust-0.8.4-x86_64-apple-darwin.tar.xz"
      sha256 "ab4bcfcbcb1c94ae635019e4a2fb15e2af2fa804da6891a82e851a07a98d5581"
    end
  end
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install "dust"
    bash_completion.install "etc/completions/dust.bash" => "dust"
    fish_completion.install "etc/completions/dust.fish"
    zsh_completion.install "etc/completions/_dust"
  end

  test do
    # failed with Linux CI run, but works with local run
    # https://github.com/Homebrew/homebrew-core/pull/121789#issuecomment-1407749790
    if OS.linux?
      system bin/"dust", "-n", "1"
    else
      assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
    end
  end
end
