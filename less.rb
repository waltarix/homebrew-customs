class Less < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "https://github.com/waltarix/less/releases/download/v551-custom-r1/less-551.tar.gz"
  sha256 "0ec1caa40a9e2bc4eac98d0c44024036ce99b7632494534793974e5154f7b028"
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
