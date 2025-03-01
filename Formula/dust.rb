class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  "1.1.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "42fdceb87d5dde0ce7481d313308f91b2c203b6bda48912de4d56b5ddd7aff70"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "5f022ad7be81c90b0906b63680515b55a0efecf87218d24528fe1b9b33fb5365"
      else
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "e045b377a098742ef8cc67be8239cf0c7dbb9c78e6e06ae8ad76e0384c569ae5"
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
