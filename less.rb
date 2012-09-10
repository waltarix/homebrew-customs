require 'formula'

class Less < Formula
  homepage 'http://www.greenwoodsoftware.com/less/index.html'
  url 'http://www.greenwoodsoftware.com/less/less-451.tar.gz'
  sha1 'ee95be670e8fcc97ac87d02dd1980209130423d0'

  depends_on 'pcre'
  depends_on 'waltarix/customs/ncurses'

  def install
    ENV.append "LIBS", "-L#{HOMEBREW_PREFIX}/lib -lncursesw"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--mandir=#{man}", "--with-regex=pcre"
    system "make install"
  end

  def test
    system "#{bin}/lesskey"
  end
end
