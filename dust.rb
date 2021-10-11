class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.7.5-custom-r1/dust-0.7.5-x86_64-unknown-linux-musl.tar.xz"
    sha256 "bb10b7c7c91b2a9967c6ef247b52fa796889d4cfeb017e54134214f9bafc2f49"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.7.5-custom-r1/dust-0.7.5-aarch64-apple-darwin.tar.xz"
      sha256 "545329daab41ad1ac868a139b4d61d9dca36f09471b79d627851dedc1a38ded6"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.7.5-custom-r1/dust-0.7.5-x86_64-apple-darwin.tar.xz"
      sha256 "088a34ffde94d05d0734f47ac7078e8522c2a385edc12b63ca3def976caa9ef9"
    end
  end
  license "Apache-2.0"
  revision 1
  head "https://github.com/bootandy/dust.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
