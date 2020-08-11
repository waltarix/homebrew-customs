class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.2-custom/dust-0.5.2-linux.tar.xz"
    sha256 "be0900103a06688b440109c6825c5de32a75a1f9465ea7024b0d1fc256aaeb98"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.2-custom/dust-0.5.2-darwin.tar.xz"
    sha256 "3f0aebe8adc937b94c2115de26f39b2927d7cfbb642785ab4dbd130b1fc3361a"
  end
  license "Apache-2.0"

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
