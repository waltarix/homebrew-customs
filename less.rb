class Less < Formula
  desc "Pager program similar to more"
  homepage "https://www.greenwoodsoftware.com/less/index.html"
  url "https://github.com/waltarix/less/releases/download/v590-custom-r1/less-590.tar.gz"
  sha256 "e03e26845bc9d2a5e2f1055b2faf3c11d026598f6fb33e1324185d813861151f"
  license "GPL-3.0-or-later"
  revision 1

  livecheck do
    url :homepage
    regex(/less[._-]v?(\d+(?:\.\d+)*).+?released.+?general use/i)
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
