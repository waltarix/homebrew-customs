require 'formula'

class GnuCpio < Formula
  homepage 'http://www.gnu.org/software/cpio/'
  url 'http://ftpmirror.gnu.org/cpio/cpio-2.11.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/cpio/cpio-2.11.tar.bz2'
  sha1 '6f1934b0079dc1e85ddff89cabdf01adb3a74abb'

  option 'default-names', "Do not prepend 'g' to the binary"

  patch :DATA

  def install
    args = [
      "--disable-dependency-tracking",
      "--disable-nls", "--program-prefix=g",
      "--prefix=#{prefix}", "--mandir=#{man}",
      "--docdir=#{doc}", "--infodir=#{info}"
    ]
    args << "--program-prefix=g" unless build.include? 'default-names'

    system "./configure", *args
    system "make install"
  end

  def test
    cpio = 'cpio'
    cpio[0,0] = 'g' if build.include? 'default-names'

    system "#{bin}/#{cpio}", "--version"
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
