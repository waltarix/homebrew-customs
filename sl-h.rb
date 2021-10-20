class SlH < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://packages.debian.org/stretch/sl"
  url "https://deb.debian.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz"
  version "3.03-17+b2"
  sha256 "5986d9d47ea5e812d0cbd54a0fc20f127a02d13b45469bb51ec63856a5a6d3aa"

  depends_on "ncurses"

  resource "debian" do
    url "https://deb.debian.org/debian/pool/main/s/sl/sl_3.03-17.debian.tar.gz"
    sha256 "f51b223c84729f48633b78e784c72752a333c3a1ff74441cf661f7db65bb008e"
  end

  patch do
    url "https://deb.debian.org/debian/pool/main/s/sl/sl_3.03-17.debian.tar.gz"
    sha256 "f51b223c84729f48633b78e784c72752a333c3a1ff74441cf661f7db65bb008e"
    apply "patches/modify_Makefile.patch",
          "patches/remove_SIGINT.patch",
          "patches/add_-e_option.patch",
          "patches/apply_sl-h.patch",
          "patches/set_curs.patch"
  end

  def install
    ENV.append "LDFLAGS", "-lncursesw"

    system "make", "-e"
    bin.install "sl-h"

    resource("debian").stage { man6.install "man/man6/sl-h.6" }
  end

  test do
    system "#{bin}/sl-h", "-c"
  end
end
