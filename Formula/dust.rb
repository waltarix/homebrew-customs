class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  "1.2.3".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "0469232c5147d6a4f955c549f07d226d6e5f94ba2c08f56baf618aed4133fdf1"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "37915fcf947a966d7621d91b9076f185ad16be791ba82b6fc7a3cb5771d7cfb3"
      else
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "9898ab7259296390ef57a6a8f3858bdfa6e36c6906973920e72ca32dd443ce40"
      end
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
