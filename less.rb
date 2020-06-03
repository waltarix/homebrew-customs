class Less < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "https://github.com/waltarix/less/releases/download/v551-custom/less-551.tar.gz"
  sha256 "5ac661c9530ca7c6922b2ee150b94c3b28389fc485aecf037ff1057bc9a8c459"
  revision 1

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
