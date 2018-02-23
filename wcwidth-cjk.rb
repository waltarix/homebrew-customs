class WcwidthCjk < Formula
  desc "CJK-friendly wcwidth(3) to fix ambiguous width chars"
  homepage "https://github.com/fumiyas/wcwidth-cjk"
  url "https://github.com/fumiyas/wcwidth-cjk.git",
    :revision => "e4a40fc0ed5977b740171f78b9092f458c71fee8"
  version "0.2"

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
    assert_match /^2\s/, shell_output("#{bin}/wcwidth-cjk #{bin}/wcwidth 🔥")
  end
end

__END__
diff --git a/Makefile.am b/Makefile.am
index 10a3dfc..06f30da 100644
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
index bd9102f..bf73d46 100644
--- a/wcwidth.c
+++ b/wcwidth.c
@@ -129,10 +129,7 @@ int wcwidth_ucs(wchar_t ucs)
     { 0x1b6b, 0x1b73 }, { 0x1dc0, 0x1dca }, { 0x1dfe, 0x1dff },
     { 0x200b, 0x200f }, { 0x202a, 0x202e }, { 0x2060, 0x2063 },
     { 0x206a, 0x206f }, { 0x20d0, 0x20ef }, { 0x302a, 0x302f },
-#ifndef __APPLE__
-    { 0x3099, 0x309a },
-#endif
-                        { 0xa806, 0xa806 }, { 0xa80b, 0xa80b },
+    { 0x3099, 0x309a }, { 0xa806, 0xa806 }, { 0xa80b, 0xa80b },
     { 0xa825, 0xa826 }, { 0xfb1e, 0xfb1e }, { 0xfe00, 0xfe0f },
     { 0xfe20, 0xfe23 }, { 0xfeff, 0xfeff }, { 0xfff9, 0xfffb },
     { 0x10a01, 0x10a03 }, { 0x10a05, 0x10a06 }, { 0x10a0c, 0x10a0f },
@@ -260,7 +257,7 @@ int wcwidth_cjk(wchar_t ucs)
     { 0x2282, 0x2283 }, { 0x2286, 0x2287 }, { 0x2295, 0x2295 },
     { 0x2299, 0x2299 }, { 0x22a5, 0x22a5 }, { 0x22bf, 0x22bf },
     { 0x2312, 0x2312 }, { 0x2460, 0x24e9 }, { 0x24eb, 0x254b },
-    { 0x2550, 0x2573 }, { 0x2580, 0x258f }, { 0x2592, 0x2595 },
+    { 0x2550, 0x2573 }, { 0x2592, 0x2595 },
     { 0x25a0, 0x25a1 }, { 0x25a3, 0x25a9 }, { 0x25b2, 0x25b3 },
     { 0x25b6, 0x25b7 }, { 0x25bc, 0x25bd }, { 0x25c0, 0x25c1 },
     { 0x25c6, 0x25c8 }, { 0x25cb, 0x25cb }, { 0x25ce, 0x25d1 },
@@ -270,7 +267,8 @@ int wcwidth_cjk(wchar_t ucs)
     { 0x2642, 0x2642 }, { 0x2660, 0x2661 }, { 0x2663, 0x2665 },
     { 0x2667, 0x266a }, { 0x266c, 0x266d }, { 0x266f, 0x266f },
     { 0x273d, 0x273d }, { 0x2776, 0x277f }, { 0xe000, 0xf8ff },
-    { 0xfffd, 0xfffd }, { 0xf0000, 0xffffd }, { 0x100000, 0x10fffd }
+    { 0xfffd, 0xfffd }, { 0x1f000, 0x1ffff },
+    { 0xf0000, 0xffffd }, { 0x100000, 0x10fffd }
   };
 
 #ifdef JA_LEGACY
