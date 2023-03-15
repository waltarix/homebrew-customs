class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.5-custom/dust-0.8.5-x86_64-unknown-linux-musl.tar.xz"
    sha256 "5fab3a133a79fd6a07d0681cb767f40e1db49e12137d096beb4fe4210bb320e2"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.5-custom/dust-0.8.5-aarch64-apple-darwin.tar.xz"
      sha256 "cb768d44ab18797925f3821782582af1765efe0e7c048e5abc07960c520fa24a"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.5-custom/dust-0.8.5-x86_64-apple-darwin.tar.xz"
      sha256 "28242961518e30a504fa16a2e14c6450bd4f85c0d5a664b70b17935a67a99f19"
    end
  end
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install "dust"
    man1.install "manual/dust.1"
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
