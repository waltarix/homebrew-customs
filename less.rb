class Less < Formula
  desc "Pager program similar to more"
  homepage "http://www.greenwoodsoftware.com/less/index.html"
  url "https://github.com/waltarix/less/releases/download/v563-custom/less-563.tar.gz"
  sha256 "e5efb1793687a802ad8d5e1658c556ed6b4bcc37081321a176bd4c2d4bf9cb78"
  license "GPL-3.0-or-later"

  livecheck do
    url :homepage
    regex(/less[._-]v?(\d+).+?released.+?general use/i)
  end

  bottle :unneeded

  depends_on "pcre"

  uses_from_macos "ncurses"

  depends_on "ncurses"
  depends_on "pcre2"
  depends_on "waltarix/customs/cmigemo"

  # Fix build with Xcode 12 as it no longer allows implicit function declarations
  # See https://github.com/gwsw/less/issues/91
  patch :DATA

  def install
    system "./configure", "--prefix=#{prefix}", "--with-regex=pcre2"
    system "make", "install"
  end

  test do
    system "#{bin}/lesskey", "-V"
  end
end
__END__
diff --git a/configure b/configure
index 0ce6db1..eac7ca0 100755
--- a/configure
+++ b/configure
@@ -4104,11 +4104,11 @@ if test "x$TERMLIBS" = x; then
     TERMLIBS="-lncurses"
     SAVE_LIBS=$LIBS
     LIBS="$LIBS $TERMLIBS"
     cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
+#include <termcap.h>
 int
 main ()
 {
 tgetent(0,0); tgetflag(0); tgetnum(0); tgetstr(0,0);
   ;
