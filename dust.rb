class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.8.1-custom/dust-0.8.1-x86_64-unknown-linux-musl.tar.xz"
    sha256 "37e1e458704206c93a7cd532731b69378ed0b8c2fd3958ef47a1b45d26c9091a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dust/releases/download/v0.8.1-custom/dust-0.8.1-aarch64-apple-darwin.tar.xz"
      sha256 "7112b8be62697aaad3483e34f4d352c24d6723c56ebd6861a62a025eff29b997"
    else
      url "https://github.com/waltarix/dust/releases/download/v0.8.1-custom/dust-0.8.1-x86_64-apple-darwin.tar.xz"
      sha256 "79bf76501613a814b651a672ee17cda91b266bca20ae7ae0772dac83a0ea81c0"
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
  end

  test do
    assert_match(/\d+.+?\./, shell_output("#{bin}/dust -n 1"))
  end
end
