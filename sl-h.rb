class SlH < Formula
  desc "Prints a steam locomotive if you type sl instead of ls"
  homepage "https://github.com/mtoyoda/sl"
  url "https://deb.debian.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz"
  version "3.03-17build2"
  sha256 "5986d9d47ea5e812d0cbd54a0fc20f127a02d13b45469bb51ec63856a5a6d3aa"

  bottle :unneeded

  depends_on "ncurses"

  resource "debian" do
    url "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/sl/3.03-17build2/sl_3.03-17build2.debian.tar.xz"
    sha256 "7a5ad04027f1ad902c67800f97982e2ebdbf75b39989408b66db817dba56a44e"
  end

  patch do
    url "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/sl/3.03-17build2/sl_3.03-17build2.debian.tar.xz"
    sha256 "7a5ad04027f1ad902c67800f97982e2ebdbf75b39989408b66db817dba56a44e"
    apply "patches/modify_Makefile.patch",
          "patches/remove_SIGINT.patch",
          "patches/add_-e_option.patch",
          "patches/apply_sl-h.patch",
          "patches/set_curs.patch"
  end

  def install
    ncurses = Formula["ncurses"]
    ENV.append "CFLAGS", "-I#{ncurses.opt_include}"
    ENV.append "LDFLAGS", "-L#{ncurses.opt_lib}"
    ENV.append "LDFLAGS", "-lncursesw"

    system "make", "-e"
    bin.install "sl-h"

    resource("debian").stage { man6.install "man/man6/sl-h.6" }
  end

  test do
    system "#{bin}/sl", "-c"
  end
end
