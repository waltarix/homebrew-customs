class Less < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "https://github.com/waltarix/less/releases/download/v563-custom-r2/less-563.tar.gz"
  sha256 "96dd131f08d375ba44db79bec54e8d5c1315043e012b19be9b02b31eac543f25"
  license "GPL-3.0-or-later"
  revision 2

  livecheck do
    url :homepage
    regex(/less[._-]v?(\d+).+?released.+?general use/i)
  end

  bottle :unneeded

  depends_on "ncurses"
  depends_on "pcre2"
  depends_on "waltarix/customs/cmigemo"

  def install
    system "./configure", "--prefix=#{prefix}", "--with-regex=pcre2"
    system "make", "install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
