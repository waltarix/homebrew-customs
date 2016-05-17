class WcwidthCjk < Formula
  homepage 'https://github.com/fumiyas/wcwidth-cjk'
  url 'https://github.com/fumiyas/wcwidth-cjk.git',
    :revision => 'ac3a9ceb020c7499da0b347ec9918b87b253b7a8'
  version '0.1'

  depends_on 'libtool' => :build
  depends_on 'automake' => :build
  depends_on 'autoconf' => :build

  patch :DATA

  def install
    system "autoreconf", "-i"

    system "./configure", "--prefix=#{prefix}"

    system "make"
    system "make", "install"
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
