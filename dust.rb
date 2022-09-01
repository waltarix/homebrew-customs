class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.3-custom/dust-0.8.3-x86_64-unknown-linux-musl.tar.xz"
    sha256 "2161f0324999ce50027684e6cdc73c3338252df85f46ee3d0765f8348def42ea"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.3-custom/dust-0.8.3-aarch64-apple-darwin.tar.xz"
      sha256 "8de0e5a00e9af4341393f00dbbef2ec2ecb63c3af03057b41c911b4e0d31fc8e"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.3-custom/dust-0.8.3-x86_64-apple-darwin.tar.xz"
      sha256 "e342fb5513d504245e15e742bbef4fed8757bad7244e6e5419a126e95c0291c3"
    end
  end
  license "Apache-2.0"
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
