class Dust < Formula
  desc "More intuitive version of du in rust"
  homepage "https://github.com/bootandy/dust"
  if OS.linux?
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom-r2/dust-0.5.1-linux.tar.xz"
    sha256 "5619c04d83b110252c6b085d12f7a6be9a15adb694691210f37d141908e8d3ed"
  else
    url "https://github.com/waltarix/dust/releases/download/v0.5.1-custom-r2/dust-0.5.1-darwin.tar.xz"
    sha256 "625daf203972135b734113dc6864454f76401f2a012c33ea1b6c2644200005ef"
  end
  revision 2

  bottle :unneeded

  def install
    bin.install "dust"
  end

  test do
    assert_match /\d+.+?\./, shell_output("#{bin}/dust -n 1")
  end
end
