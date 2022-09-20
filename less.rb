class Less < Formula
  desc "Pager program similar to more"
  homepage "https://www.greenwoodsoftware.com/less/index.html"
  url "https://github.com/waltarix/less/releases/download/v608-custom-r1/less-608.tar.gz"
  sha256 "16dd5d56ad6cd7eb2fe16140f74822cf23c0b716d3c429a2410ba6c34be60696"
  license "GPL-3.0-or-later"
  revision 1

  livecheck do
    url :homepage
    regex(/less[._-]v?(\d+(?:\.\d+)*).+?released.+?general use/i)
  end

  depends_on "ncurses"
  depends_on "pcre2"
  depends_on "waltarix/customs/cmigemo"

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"

    system "./configure", "--prefix=#{prefix}", "--with-regex=pcre2"
    system "make", "install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
