class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom-r1/dust-0.8.2-x86_64-unknown-linux-musl.tar.xz"
    sha256 "4c5eb393235df0cb41bd93a25ce788f54adf1b02febde9c6009e327c73157a74"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom-r1/dust-0.8.2-aarch64-apple-darwin.tar.xz"
      sha256 "0ac0f036727168ad0b272b6e5c537eb1c053298bd047ba1aa9e451de685fd1c3"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.2-custom-r1/dust-0.8.2-x86_64-apple-darwin.tar.xz"
      sha256 "7018f6d476fd2acc2ab50c40ce762e7d635c554e5d1ce2c6d8af26773f5d48f4"
    end
  end
  license "Apache-2.0"
  revision 1
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
