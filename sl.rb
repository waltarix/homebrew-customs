class Sl < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://packages.debian.org/sid/sl"
  url "https://deb.debian.org/debian/pool/main/s/sl/sl_5.02.orig.tar.gz"
  version "5.02-1"
  sha256 "1e5996757f879c81f202a18ad8e982195cf51c41727d3fea4af01fdcbbb5563a"

  bottle :unneeded

  depends_on "ncurses"

  resource "debian" do
    url "https://deb.debian.org/debian/pool/main/s/sl/sl_5.02-1.debian.tar.xz"
    sha256 "f25d8583951456d4889e72587856924d341652dcd1725e374a98971a1fdf8b55"
  end

  patch do
    url "https://deb.debian.org/debian/pool/main/s/sl/sl_5.02-1.debian.tar.xz"
    sha256 "f25d8583951456d4889e72587856924d341652dcd1725e374a98971a1fdf8b55"
    apply "patches/modify_Makefile.patch",
          "patches/add_-e_option.patch"
  end

  def install
    system "make", "-e"
    bin.install "sl"

    resource("debian").stage { man6.install "man/man6/sl.6" }
  end

  test do
    system "#{bin}/sl", "-c"
  end
end
