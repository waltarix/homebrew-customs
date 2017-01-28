class WcwidthCjk < Formula
  desc "CJK-friendly wcwidth(3) to fix ambiguous width chars"
  homepage "https://github.com/fumiyas/wcwidth-cjk"
  url "https://github.com/fumiyas/wcwidth-cjk.git",
    :revision => "ac3a9ceb020c7499da0b347ec9918b87b253b7a8"
  version "0.1"
  revision 1

  depends_on "libtool" => :build
  depends_on "automake" => :build
  depends_on "autoconf" => :build

  patch :DATA

  def install
    system "autoreconf", "-i"

    system "./configure", "--prefix=#{prefix}"

    system "make"
    system "make", "install"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["LANG"] = "en_US.UTF-8"
    assert_match /^1\s/, shell_output("#{bin}/wcwidth ☆")
    assert_match /^2\s/, shell_output("#{bin}/wcwidth-cjk #{bin}/wcwidth ☆")
    assert_match /^1\s/, shell_output("#{bin}/wcwidth-cjk #{bin}/wcwidth ▀")
  end
end

__END__
diff --git a/Makefile.am b/Makefile.am
index 8df9ea6..c3e73d3 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -1,9 +1,9 @@
 bin_SCRIPTS = wcwidth-cjk
 CLEANFILES = $(bin_SCRIPTS)
 
-lib_LTLIBRARIES = wcwidth-cjk.la
-wcwidth_cjk_la_SOURCES = wcwidth.c
-wcwidth_cjk_la_LDFLAGS = -module -avoid-version
+lib_LTLIBRARIES = libwcwidth-cjk.la
+libwcwidth_cjk_la_SOURCES = wcwidth.c
+libwcwidth_cjk_la_LDFLAGS = -avoid-version
 
 bin_PROGRAMS = wcwidth
 wcwidth_SOURCES = wcwidth-cmd.c
diff --git a/wcwidth-cjk.in b/wcwidth-cjk.in
index 4510abd..09859f1 100755
--- a/wcwidth-cjk.in
+++ b/wcwidth-cjk.in
@@ -5,7 +5,7 @@ exec_prefix=@exec_prefix@
 bindir=@bindir@
 libdir=@libdir@
 
-wcwidth_cjk_so="$libdir/wcwidth-cjk.@SHARED_LIB_EXT@"
+wcwidth_cjk_so="$libdir/libwcwidth-cjk.@SHARED_LIB_EXT@"
 
 if [ $# -lt 1 ]; then
   echo "Usage: $0 COMMAND [ARGUMENT ...]" 1>&2
diff --git a/wcwidth.c b/wcwidth.c
index c5c62bf..865012a 100644
--- a/wcwidth.c
+++ b/wcwidth.c
@@ -257,7 +257,7 @@ int wcwidth_cjk(wchar_t ucs)
     { 0x2282, 0x2283 }, { 0x2286, 0x2287 }, { 0x2295, 0x2295 },
     { 0x2299, 0x2299 }, { 0x22a5, 0x22a5 }, { 0x22bf, 0x22bf },
     { 0x2312, 0x2312 }, { 0x2460, 0x24e9 }, { 0x24eb, 0x254b },
-    { 0x2550, 0x2573 }, { 0x2580, 0x258f }, { 0x2592, 0x2595 },
+    { 0x2550, 0x2573 }, { 0x2592, 0x2595 },
     { 0x25a0, 0x25a1 }, { 0x25a3, 0x25a9 }, { 0x25b2, 0x25b3 },
     { 0x25b6, 0x25b7 }, { 0x25bc, 0x25bd }, { 0x25c0, 0x25c1 },
     { 0x25c6, 0x25c8 }, { 0x25cb, 0x25cb }, { 0x25ce, 0x25d1 },
