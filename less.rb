require 'formula'

class Less < Formula
  homepage 'http://www.greenwoodsoftware.com/less/index.html'
  url 'http://www.greenwoodsoftware.com/less/less-458.tar.gz'
  sha1 'd5b07180d3dad327ccc8bc66818a31577e8710a2'

  depends_on 'pcre'
  depends_on 'waltarix/customs/ncurses'

  def install
    ENV.append "LIBS", "-L#{HOMEBREW_PREFIX}/lib -lncursesw"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--mandir=#{man}", "--with-regex=pcre"
    system "make install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
