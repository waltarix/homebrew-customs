class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  "1.2.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "3590df4e31416da7d46123cfd366d8f943ff0f8b6cebc71e42346e28a38a47ff"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "8ee8c344c271704765bbdad57eff87fd0aa345d1ea2140dd46b96d8cafc9b8fb"
      else
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "5df4da11e5bdbb54cc80a139278e165fe41fbc0f1bbdddaf0b3dfd439b3f56f3"
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
