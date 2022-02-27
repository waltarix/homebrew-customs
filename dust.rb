class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.0-custom/dust-0.8.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "563599e2345b5820bbc65eb381dc38f9a585d874470128ab8ca2c23262366618"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.0-custom/dust-0.8.0-aarch64-apple-darwin.tar.xz"
      sha256 "33502eab6610d5a5a535768e6c902e5807171d4078b06ae1521311578a3054c3"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.0-custom/dust-0.8.0-x86_64-apple-darwin.tar.xz"
      sha256 "cc41d52890726e83d116e21e8b8e61080e2b69da37114f1512f4232dc0a9b5f9"
    end
  end
  license "Apache-2.0"
  head "https://github.com/bootandy/dust.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install "dust"
  end

  test do
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
