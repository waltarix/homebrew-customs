class GnuCpio < Formula
  desc "GNU cpio copies files into or out of a cpio or tar archive"
  homepage "https://www.gnu.org/software/cpio/"
  url "https://ftp.gnu.org/gnu/cpio/cpio-2.11.tar.bz2"
  mirror "https://ftpmirror.gnu.org/cpio/cpio-2.11.tar.bz2"
  sha256 "bb820bfd96e74fc6ce43104f06fe733178517e7f5d1cdee553773e8eff7d5bbd"

  option "with-default-names", "Do not prepend 'g' to the binary"

  patch :DATA

  def install
    args = [
      "--disable-dependency-tracking",
      "--disable-nls", "--program-prefix=g",
      "--prefix=#{prefix}", "--mandir=#{man}",
      "--docdir=#{doc}", "--infodir=#{info}"
    ]
    args << "--program-prefix=g" unless build.include? "default-names"

    system "./configure", *args
    system "make", "install"
  end

  test do
    cpio = "cpio"
    cpio[0, 0] = "g" if build.include? "default-names"

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
