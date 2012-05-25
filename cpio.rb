require 'formula'

class Cpio < Formula
  homepage 'http://www.gnu.org/software/cpio/'
  url 'http://ftpmirror.gnu.org/cpio/cpio-2.11.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/cpio/cpio-2.11.tar.bz2'
  md5 '20fc912915c629e809f80b96b2e75d7d'

  def patches
    DATA
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-nls", "--program-prefix=g",
                          "--prefix=#{prefix}", "--mandir=#{man}",
                          "--docdir=#{doc}", "--infodir=#{info}"
    system "make install"
  end

  def test
    system "#{bin}/gcpio", "--version"
  end
end

__END__
--- a/src/filetypes.h
+++ b/src/filetypes.h
@@ -82,4 +82,3 @@
 #define lstat stat
 #endif
 int lstat ();
-int stat ();
