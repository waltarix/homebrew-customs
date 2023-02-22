class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://packages.debian.org/sid/w3m"
  url "https://deb.debian.org/debian/pool/main/w/w3m/w3m_0.5.3+git20230121.orig.tar.xz"
  version "0.5.3+git20230121-2"
  sha256 "974d1095a47f1976150a792fe9c5a44cc821c02b6bdd714a37a098386250e03a"

  livecheck do
    url "https://deb.debian.org/debian/pool/main/w/w3m/"
    regex(/href=.*?w3m[._-]v?(\d+(?:\.\d+)+)\.orig\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "brotli"
  depends_on "bzip2"
  depends_on "ncurses"
  depends_on "openssl@3"
  depends_on "waltarix/customs/cmigemo"
  depends_on "zlib"

  on_linux do
    depends_on "gettext"
  end

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/15.0.0-r4/wcwidth9.h"
    sha256 "81974cfee64faece46162923a3ed3a70b9dfb7723005103730718bf2dded6ab5"
  end

  patch :DATA

  def install
    resource("wcwidth9.h").stage(buildpath/"libwc")

    # Work around configure issues with Xcode 12
    ENV.append "CFLAGS", "-Wno-implicit-function-declaration"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-gopher",
                          "--disable-w3mmailer",
                          "--enable-image=no",
                          "--enable-japanese=U",
                          "--enable-m17n",
                          "--enable-nls",
                          "--enable-unicode",
                          "--with-migemo='cmigemo -c -q'",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}",
                          "--with-termlib=ncursesw"
    system "make", "install"
  end

  test do
    assert_match "DuckDuckGo", shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end

__END__
diff --git a/libwc/ucs.c b/libwc/ucs.c
index 18c3a67..6140f74 100644
--- a/libwc/ucs.c
+++ b/libwc/ucs.c
@@ -15,6 +15,8 @@
 #include "viet.h"
 #include "wtf.h"
 
+#include "wcwidth9.h"
+
 #include "ucs.map"
 
 #include "map/ucs_ambwidth.map"
@@ -536,14 +538,7 @@ wc_ucs_to_ccs(wc_uint32 ucs)
 wc_bool
 wc_is_ucs_ambiguous_width(wc_uint32 ucs)
 {
-    if (0xa1 <= ucs && ucs <= 0xfe && WcOption.use_jisx0213)
-	return 1;
-    else if (ucs <= WC_C_UCS2_END)
-	return (wc_map_range_search((wc_uint16)ucs,
-		    ucs_ambwidth_map, N_ucs_ambwidth_map) != NULL);
-    else
-	return ((0xF0000 <= ucs && ucs <= 0xFFFFD)
-		|| (0x100000 <= ucs && ucs <= 0x10FFFD));
+  return wcwidth9(ucs) == 2;
 }
 
 wc_bool
