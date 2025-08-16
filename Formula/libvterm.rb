class Libvterm < Formula
  desc "C99 library which implements a VT220 or xterm terminal emulator"
  homepage "http://www.leonerd.org.uk/code/libvterm/"
  url "https://github.com/neovim/libvterm/archive/v0.3.3.tar.gz"
  sha256 "0babe3ab42c354925dadede90d352f054aa9c4ae6842ea803a20c9741e172e56"
  license "MIT"
  revision 2
  version_scheme 1

  livecheck do
    url :homepage
    regex(/href=.*?libvterm[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  depends_on "libtool" => :build

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/16.0.0/wcwidth9.h"
    sha256 "a9ddb9059f0a17dc0efee89e7ed73c9b0412b10111987090068f49ba708bfa70"
  end

  patch :DATA

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    resource("wcwidth9.h").stage(buildpath/"src")

    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <vterm.h>

      int main() {
        vterm_free(vterm_new(1, 1));
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lvterm", "-o", "test"
    system "./test"
  end
end

__END__
diff --git a/src/unicode.c b/src/unicode.c
index 0d1b5ff..28ea8c5 100644
--- a/src/unicode.c
+++ b/src/unicode.c
@@ -1,4 +1,5 @@
 #include "vterm_internal.h"
+#include "wcwidth9.h"
 
 // ### The following from http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
 // With modifications:
@@ -325,10 +326,7 @@ static const struct interval fullwidth[] = {
 
 INTERNAL int vterm_unicode_width(uint32_t codepoint)
 {
-  if(bisearch(codepoint, fullwidth, sizeof(fullwidth) / sizeof(fullwidth[0]) - 1))
-    return 2;
-
-  return mk_wcwidth(codepoint);
+  return wcwidth9(codepoint);
 }
 
 INTERNAL int vterm_unicode_is_combining(uint32_t codepoint)
