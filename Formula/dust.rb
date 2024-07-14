class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  "1.0.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "c5c94ed2747f334c9047a2aca73904e9343c2cb8da45ac0f0d16b979980c62ce"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "adcfcb24fe5ba2f9d8732684ef50f6fdab7858e9a58f1b78b7723fb7d01dcd26"
      else
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "75af806a6a2d11ee84c6485c47c3c493dce1d514696678ed8a26973a2a7a4267"
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
    bash_completion.install "etc/completions/dust.bash"
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
