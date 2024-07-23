class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  "1.1.1".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "0128074ad4890183387f7023e88902d53de98e2ffca506f72c44b300aabfc8e9"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "0b016370ef01cc5d6ff7e672da42b368823420ff32c3fbe4ad95bcc26c25dd21"
      else
        url "https://github.com/waltarix/dust/releases/download/v#{v}-custom/dust-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "9d5c20bf390aedb2ae8736a3fc34de3f0488d89997270774de63fce97026cd16"
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
