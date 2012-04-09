require 'formula'

class Less < Formula
  url 'http://www.greenwoodsoftware.com/less/less-444.tar.gz'
  homepage 'http://www.greenwoodsoftware.com/less/index.html'
  md5 '56f9f76ffe13f70155f47f6b3c87d421'

  def install
    ENV.append "LIBS", "-lncurses"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--mandir=#{man}", "--with-regex=pcre"
    system "make install"
  end
end