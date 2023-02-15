class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.4-custom-r1/dust-0.8.4-x86_64-unknown-linux-musl.tar.xz"
    sha256 "3fb5a511ab81c52918f2d88b76d7ff8ccb6d460a0e9ace7b8e5d54bfd78e1966"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.4-custom-r1/dust-0.8.4-aarch64-apple-darwin.tar.xz"
      sha256 "194f99fb401b37615d92fc9aaa99b1eea8f54eca9112939702ef162fb3069c54"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.4-custom-r1/dust-0.8.4-x86_64-apple-darwin.tar.xz"
      sha256 "3c808a65d4797aa4f81c73470370e04be1d86d68f973402faebd429abadc320e"
    end
  end
  license "Apache-2.0"
  revision 1

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
