class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom-r2/dust-0.8.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "f6913db065a544fa5ff378b0ef358ffa68ccc2c39f8aae16ad1f83c91c7867ff"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom-r2/dust-0.8.2-aarch64-apple-darwin.tar.xz"
      sha256 "067634714282b4f3a2a26e1011facc6ead30c5d669fc3e33fc9401010875520f"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom-r2/dust-0.8.2-x86_64-apple-darwin.tar.xz"
      sha256 "7ba057eccbcc002cbba25196a8f6ce6e5e42e157fbaae6801271cd37597c0e12"
    end
  end
  license "Apache-2.0"
  revision 2
  head "https://github.com/bootandy/dust.git", branch: "master"

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
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
