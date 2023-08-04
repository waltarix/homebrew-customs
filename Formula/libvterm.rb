class Libvterm < Formula
  desc "C99 library which implements a VT220 or xterm terminal emulator"
  homepage "http://www.leonerd.org.uk/code/libvterm/"
  url "https://launchpad.net/libvterm/trunk/v0.3/+download/libvterm-0.3.3.tar.gz"
  sha256 "09156f43dd2128bd347cbeebe50d9a571d32c64e0cf18d211197946aff7226e0"
  license "MIT"
  version_scheme 1

  livecheck do
    url :homepage
    regex(/href=.*?libvterm[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  depends_on "libtool" => :build

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0-r5/wcwidth9.h"
    sha256 "3272d3b4e3b2068f52093f99609c2ebbe35f60e879daa9ab96481c76f7ce5250"
  end

  patch :DATA

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
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
